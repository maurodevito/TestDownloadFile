# App Test Download File - (iOS - Swift)
Download an audio file (iOS/Swift) and make it visible in app "Files"

## Main Steps

**Add in `info.plist` these two keys :**
```
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

## To show the view controller for saving (not implemented):
```
UIDocumentInteractionController
```
