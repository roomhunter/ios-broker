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
    
    unowned var mediaController: ApartmentMediaUploadViewController
    let videoActionSheet = UIActionSheet(title: "Video From", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "From Library")
    var delegate: ApartmentVideoUploadDelegate?
    
    init(mediaController: ApartmentMediaUploadViewController) {
        self.mediaController = mediaController
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
        // we get thumbnail first, then make the request. because encoding video takes time
        return mediaController.newApartment.videoThumbnails.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        
        // add image button / add video button
        if row == mediaController.newApartment.videoThumbnails.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddVideoButtonCell", forIndexPath: indexPath) as! UICollectionViewCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UploadingImageCell", forIndexPath: indexPath) as! UploadingImageCell

        // image cell
        cell.imageView.image = mediaController.newApartment.videoThumbnails[row]
        cell.coverLabel.hidden = true
        
        // is faild
        if mediaController.newApartment.failedVideoRequests[row] != nil {
            cell.progress = -1.0
            return cell
        }
        
        // haven't made this request yet
        if row >= mediaController.newApartment.videoUploadRequests.count {
            cell.progress = 0.0
            return cell
        }
        
        if let uploadRequest = mediaController.newApartment.videoUploadRequests[row] {
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
            videoActionSheet.showInView(mediaController.tableView)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let url = info[UIImagePickerControllerMediaURL] as! NSURL
        let thumbnail = generateThumbnailFromVideoUrl(url)
        mediaController.newApartment.videoThumbnails.append(thumbnail)
        let items = mediaController.newApartment.videoThumbnails.count - 1
        mediaController.videoCollectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: items, inSection: 0)])
        mediaController.refreshSubmitButton()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { [unowned self] in
            self.compressVideoFromUrl(url)
            dispatch_async(dispatch_get_main_queue(), {
                self.mediaController.videoCollectionView?.reloadData()
                self.mediaController.refreshSubmitButton()
            })
            })
    }
    func compressVideoFromUrl(url: NSURL) {
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mp4")
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("upload").stringByAppendingPathComponent(fileName)
        let outputFileUrl = NSURL(fileURLWithPath: filePath)
        let videoAsset = AVURLAsset(URL: url, options: nil)
        let exportSession = SDAVAssetExportSession(asset: videoAsset)
        exportSession.outputURL = NSURL(fileURLWithPath: filePath)
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.videoSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: 420, AVVideoHeightKey: 420, AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 900000, AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel]]
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
                self.mediaController.newApartment.videoUploadRequests.append(uploadRequest)
                self.mediaController.newApartment?.videoUrls.append(nil)
                self.upload(uploadRequest)
            }
        })
    }
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { [unowned self] (task) -> AnyObject! in
            if let error = task.error {
                
                if let index = self.mediaController.indexOfUploadRequest(self.mediaController.newApartment.videoUploadRequests, uploadRequest: uploadRequest) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let indexPath = NSIndexPath(forRow: index, inSection: 0)

                        self.mediaController.newApartment.failedVideoRequests[index] = true
                        self.mediaController.videoCollectionView?.reloadItemsAtIndexPaths([indexPath])
                        self.mediaController.refreshSubmitButton()
                        
                    })
                    println("upload() failed: [\(index)]")
                    
                }
            }
            
            // finished
            if task.result != nil {
                if let index = self.mediaController.indexOfUploadRequest(self.mediaController.newApartment.videoUploadRequests, uploadRequest: uploadRequest) {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.mediaController.newApartment.videoUrls[index] = "https://d1mnrj0eye9ccu.cloudfront.net/\(uploadRequest.key)"
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.mediaController.refreshSubmitButton()
                        self.mediaController.videoCollectionView?.reloadItemsAtIndexPaths([indexPath])
                    })
                }
            }
            return nil
        }
    }
    
    // get the thumbnail of the video
    func generateThumbnailFromVideoUrl(url: NSURL) -> UIImage {
        let imageGenerator = AVAssetImageGenerator(asset: AVAsset.assetWithURL(url) as! AVAsset)
        let cgimage = imageGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil, error: nil)
        return UIImage(CGImage: cgimage)!
    }
}
