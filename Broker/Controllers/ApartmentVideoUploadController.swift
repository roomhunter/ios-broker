//
//  ApartmentVideoUploadController.swift
//  Broker
//
//  Created by to0 on 7/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit
import AVFoundation

protocol ApartmentVideoUploadDelegate {
    func didSelectToRecordVideo()
    func didSelectToPickFromLibrary()
}

class ApartmentVideoUploadController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var newApartment: ApartmentModel!
    var tableView: UITableView!
    let videoActionSheet = UIActionSheet(title: "Video From", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "From Library")
    var delegate: ApartmentVideoUploadDelegate?
    
    override init() {
        super.init()
        videoActionSheet.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            videoActionSheet.addButtonWithTitle("Take Video")
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0: // from library
            delegate?.didSelectToPickFromLibrary()
        case 2: // form camera
            if buttonIndex != actionSheet.cancelButtonIndex {
                delegate?.didSelectToRecordVideo()
            }
        default:
            break
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newApartment.videoUploadRequests.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        
        // add image button / add video button
        if row == newApartment.videoUploadRequests.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddVideoButtonCell", forIndexPath: indexPath) as! UICollectionViewCell
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UploadingImageCell", forIndexPath: indexPath) as! UploadingImageCell

        // image cell
        cell.imageView.image = newApartment.imageThumbnails[row]
        cell.coverLabel.hidden = true
        
        if newApartment.failedRequests[row] != nil {
            cell.progress = -1.0
            return cell
        }
        
        if let uploadRequest = newApartment.uploadRequests[row] {
            switch uploadRequest.state {
            case .Running:
                uploadRequest.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if totalBytesExpectedToSend > 0 {
                            cell.progress = Float(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
                        }
                    })
                }
                break
                
            case .Completed:
                cell.progress = 1.0
                if let coverIndex = newApartment.coverIndex {
                    if coverIndex == row {
                        cell.coverLabel.hidden = false
                    }
                    else {
                        cell.coverLabel.hidden = true
                    }
                }
            case .NotStarted:
                cell.progress = 0.0
                // upload progress
                uploadRequest.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if totalBytesExpectedToSend > 0 {
                            cell.progress = Float(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
                        }
                    })
                }
            default:
                cell.imageView.image = nil
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        // last item
        if row + 1 == collectionView.numberOfItemsInSection(0) {
            videoActionSheet.showInView(self.tableView)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let url = info[UIImagePickerControllerMediaURL] as! NSURL
        compressVideoFromUrl(url)
//        UISaveVideoAtPathToSavedPhotosAlbum(path, self, nil, nil)
    }
    func compressVideoFromUrl(url: NSURL) {
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mp4")
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("upload").stringByAppendingPathComponent(fileName)
        let outputFileUrl = NSURL(fileURLWithPath: filePath)
        let videoAsset = AVURLAsset(URL: url, options: nil)
//        let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality)
        let exportSession = SDAVAssetExportSession(asset: videoAsset)
        exportSession.outputURL = NSURL(fileURLWithPath: filePath)
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.videoSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: 320, AVVideoHeightKey: 480, AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 900000, AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel]]
        exportSession.audioSettings = [AVFormatIDKey: kAudioFormatMPEG4AAC, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100, AVEncoderBitRateKey: 72000]
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronouslyWithCompletionHandler({
            if exportSession.status == AVAssetExportSessionStatus.Completed {
                let uploadRequest = AWSS3TransferManagerUploadRequest()
                uploadRequest.body = outputFileUrl
                uploadRequest.key = "apartment-videos/\(fileName)"
                uploadRequest.bucket = "roomhunter-static"
                uploadRequest.contentType = "video/mp4" // video/quicktime
                uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
                self.upload(uploadRequest)
            }
        })
    }
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { [unowned self] (task) -> AnyObject! in
            if let error = task.error {
                
//                if let index = self.indexOfUploadRequest(self.newApartment.uploadRequests, uploadRequest: uploadRequest) {
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        self.newApartment.failedRequests[index] = true
//                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
//                        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
//                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
//                        
//                    })
//                    println("upload() failed: [\(index)]")
//                    
//                }
            }
            
            // finished
            if task.result != nil {
//                if let index = self.indexOfUploadRequest(self.newApartment.uploadRequests, uploadRequest: uploadRequest) {
//                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
//                    self.newApartment.imageUrls[index] = "https://d1mnrj0eye9ccu.cloudfront.net/\(uploadRequest.key)"
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
//                        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
//                    })
//                }
            }
            return nil
        }
    }
}
