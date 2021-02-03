//
//  ViewController.swift
//  TestDownloadFile
//
//  Created by Mauro De Vito on 02/02/2021.
//  Copyright © 2021 Mauro De Vito. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func buttonPressed(_ sender: Any) {
//        https://mdv-alexa-pecorella-lella.s3-eu-west-1.amazonaws.com/audio.mp3
        let urlString = "https://mdv-alexa-pecorella-lella.s3-eu-west-1.amazonaws.com/audio.mp3"
        self.downloadAudioFile("Verbal Order", urlString, "mp3") { (response) in
            print(response)
        }
    }
    
    
    func downloadAudioFile(_ name: String, _ url: String, _ type: String, completion: @escaping (String) -> Void) {
        let service = DownloadManager()
        service.downloadAudioFile(name, url, type) { (response) in
            print("Ritorno dal DownloadManager")
            switch response {
            case .remoteFileExists_downloadSuccess:
                print(".remoteFileExists_downloadSuccess")
            case .remoteFileExists_downloadError:
                print(".remoteFileExists_downloadError")
            case .remoteFileRemoteNOTExists_downloadError:
                print(".remoteFileRemoteNOTExists_downloadError")
            }
            
            
        }
    }

}

