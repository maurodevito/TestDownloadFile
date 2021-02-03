//
//  DownloadManager.swift
//  TestDownloadFile
//
//  Created by Mauro De Vito on 02/02/2021.
//  Copyright © 2021 Mauro De Vito. All rights reserved.
//

import Foundation

enum OrderTrackingDownloadVerbalOrderState {
    case remoteFileExists_downloadSuccess
    case remoteFileExists_downloadError
    case remoteFileRemoteNOTExists_downloadError
}

class DownloadManager: NSObject, URLSessionDelegate {
    
    
    func checkRemoteFileExists(url: URL, completion: @escaping (Bool) -> Void) {
        let checkSession = URLSession.init(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5

        let task = checkSession.dataTask(with: request) { (data, response, error) -> Void in
            if let httpResp = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    completion(httpResp.statusCode == 200)
                }
            }
        }
        task.resume()
    }
    
    func downloadAudioFile(_ name: String, _ url: String, _ type: String, completion: @escaping (OrderTrackingDownloadVerbalOrderState) -> Void) {
        
        //            let stringa = url.replacingOccurrences(of: "000", with: "123")
        let stringa = url
        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        guard let url = URL(string: stringa) else {
            DispatchQueue.main.async {
                completion(.remoteFileRemoteNOTExists_downloadError)
            }
            return
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        request.timeoutInterval = 20
        
        
        
        self.checkRemoteFileExists(url: url) { (fileExists) in
            if fileExists {
                
                var documentsURL: URL?
                do {
                    documentsURL = try FileManager.default.url(
                        for: .documentDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true
                    )
                } catch {
                    print("impossible get destinationFolder")
                    DispatchQueue.main.async {
                        completion(.remoteFileRemoteNOTExists_downloadError)
                    }
                    
                }
                
                if let fileURL = documentsURL?.appendingPathComponent(name).appendingPathExtension(type) {
                    
                    // MDV: check if the file already exists at path
                    if FileManager().fileExists(atPath: fileURL.path) {
                        do {
                            let _  = try FileManager().removeItem(at: fileURL)  // MDV: Try to delete file
                            print("MDV: try FileManager().removeItem(at: fileURL) - OK: File deleted")
                        }
                        catch {
                            print("MDV: try FileManager().removeItem(at: fileURL) - KO: Error deleting file \(fileURL.path)")
                            DispatchQueue.main.async {
                                completion(.remoteFileExists_downloadError) // MDV: remoteFileExists_downloadError
                            }
                        }
                    }
                    
                    // MDV: download file
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                            if let data = data {
                                if (try? data.write(to: fileURL, options: [.atomic])) != nil {
                                    DispatchQueue.main.async {
                                        completion(.remoteFileExists_downloadSuccess)  // MDV: remoteFileExists_downloadSuccess
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        completion(.remoteFileExists_downloadError) // MDV: remoteFileExists_downloadError
                                    }
                                }
                            }
                        })
                        task.resume()
                    })
                }
            } else {    // MDV: remoteFileRemoteNOTExists_downloadError
                DispatchQueue.main.async {
                    completion(.remoteFileRemoteNOTExists_downloadError)
                }
            }
        }
    }
    
    // MARK: - URLSessionDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
      print("Finished downloading to \(location).")
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
      print("didReceive challenge")
          if challenge.previousFailureCount > 0 {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        } else if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("unknown state. error: \(challenge.error)")
            // do something w/ completionHandler here
        }
    }

}
