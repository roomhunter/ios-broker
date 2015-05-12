//
//  ApartmentMediaUploadViewController.swift
//  Broker
//
//  Created by to0 on 5/10/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ApartmentMediaUploadViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, CTAssetsPickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagesActionSheet = UIActionSheet(title: "Image From", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "From Library")
    
    let imagesPicker = UIImagePickerController()
    let multipleImagesPicker = CTAssetsPickerController()
    var collectionView: UICollectionView?
    var submitButtonCell: ApartmentSubmitButtonCell?
    // risk: upload requests != upload images
//    var uploadRequests = [AWSS3TransferManagerUploadRequest?]()
//    var imageThumbnails = [UIImage]()
    
    var newApartment: ApartmentModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagesActionSheet.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagesActionSheet.addButtonWithTitle("Take Photo")
        }
        imagesPicker.delegate = self
        
        multipleImagesPicker.delegate = self
        multipleImagesPicker.assetsFilter = ALAssetsFilter.allPhotos()
        var error = NSErrorPointer()
        
        if !NSFileManager.defaultManager().createDirectoryAtPath(
            NSTemporaryDirectory().stringByAppendingPathComponent("upload"),
            withIntermediateDirectories: true,
            attributes: nil,
            error: error) {
                println("Creating 'upload' directory failed. Error: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 260
        default:
            return 44
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Select Images"
        default:
            return nil
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentUploadingImagesCollectionCell", forIndexPath: indexPath) as! ApartmentUploadingImagesCollectionCell
            cell.imagesCollectionView.dataSource = self
            cell.imagesCollectionView.delegate = self
            collectionView = cell.imagesCollectionView
            return cell
        
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSubmitButtonCell", forIndexPath: indexPath) as! ApartmentSubmitButtonCell
            submitButtonCell = cell
            submitButtonCell?.state = newApartment.mediaState
            return cell
        default:
            return UITableViewCell()
        }

    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0: // from library
            self.presentViewController(multipleImagesPicker, animated: true, completion: nil)
//            imagesPicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
//            self.presentViewController(imagesPicker, animated: true, completion: nil)
        case 2: // form camera
            if buttonIndex != actionSheet.cancelButtonIndex {
                imagesPicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagesPicker, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { [unowned self] in
            
            self.newApartment.imageThumbnails.append(self.getThumbnailFrom(image))
            let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = NSURL(fileURLWithPath: self.getCompressedImageUrlFrom(image))
            uploadRequest.key = "apartments/\(fileName)"
            uploadRequest.bucket = "roomhunter-static"
            uploadRequest.contentType = "image/jpeg"
            uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
            
            self.newApartment.uploadRequests.append(uploadRequest)
            self.newApartment?.imageUrls.append(nil)
            dispatch_async(dispatch_get_main_queue(), {
                let items = self.newApartment.uploadRequests.count - 1
                self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: items, inSection: 0)])
                // upload method must be called before items insertion, otherwize, it is possible that upload is finished and it reload the item before insertion
                self.upload(uploadRequest)
                
                })
            })
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { [unowned self] in

            for asset in assets {
                let representation = (asset as! ALAsset).defaultRepresentation()
                let fullImage = UIImage(CGImage: representation.fullResolutionImage().takeUnretainedValue())
            
                self.newApartment.imageThumbnails.append(self.getThumbnailFrom(fullImage!))
                let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
                
                let uploadRequest = AWSS3TransferManagerUploadRequest()
                uploadRequest.body = NSURL(fileURLWithPath: self.getCompressedImageUrlFrom(fullImage!))
                uploadRequest.key = "apartments/\(fileName)"
                uploadRequest.bucket = "roomhunter-static"
                uploadRequest.contentType = "image/jpeg"
                uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
                
                self.newApartment.uploadRequests.append(uploadRequest)
                self.newApartment.imageUrls.append(nil)
                dispatch_async(dispatch_get_main_queue(), {
                    let items = self.newApartment.uploadRequests.count - 1
                    self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: items, inSection: 0)])
                    // upload method must be called before items insertion, otherwize, it is possible that upload is finished and it reload the item before insertion
                    self.upload(uploadRequest)

                })
            }
            dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                self.multipleImagesPicker.selectedAssets = []
            })
        })
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newApartment.uploadRequests.count + 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UploadingImageCell", forIndexPath: indexPath) as! UploadingImageCell
        let row = indexPath.row
        
        if row == newApartment.uploadRequests.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddImageButtonCell", forIndexPath: indexPath) as! UICollectionViewCell
            return cell
        }
        
        cell.imageView.image = newApartment.imageThumbnails[row]
        
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
                cell.progress = -1.0
            }
        }
        
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        // last item
        if row + 1 == collectionView.numberOfItemsInSection(0) {
            imagesActionSheet.showInView(self.tableView)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        // last cell is the submit button
        if section + 1 == tableView.numberOfSections() {
            if newApartment?.mediaState == ApartmentMediaState.Ready {
                submitButtonCell?.state = ApartmentMediaState.Loading
                newApartment.submit({(res: NSDictionary) in
    
                    }, fail: {[unowned self] (err: NSError) in
    
                        let alertController = UIAlertController(title: "Failed", message: "Server Response Error", preferredStyle: .Alert)
    
                        let OKAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
                            self.submitButtonCell?.state = .Ready
                            self.submitButtonCell?.setSelected(false, animated: true)
                        }
                        alertController.addAction(OKAction)
                        
                        self.presentViewController(alertController, animated: true) {
                            
                        }
                })
                
            }

        }
    }

    // helper functions
    func getThumbnailFrom(originalImage: UIImage) -> UIImage {
        let size = CGSize(width: 80, height: 80)
        let scaledImage: UIImage
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        originalImage.drawInRect(CGRect(origin: CGPointZero, size: size))
        scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func getCompressedImageUrlFrom(originalImage: UIImage) -> String {
        let scaledImage: UIImage
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let size = CGSizeApplyAffineTransform(originalImage.size, CGAffineTransformMakeScale(0.5, 0.5))
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("upload").stringByAppendingPathComponent(fileName)
        let imageData: NSData
        // explicitly scale 1, to prevent it from double the size again(retina)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        originalImage.drawInRect(CGRect(origin: CGPointZero, size: size))
        scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageData = UIImageJPEGRepresentation(scaledImage, 0.8)
        imageData.writeToFile(filePath, atomically: true)
        
        return filePath
    }
    
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { [unowned self] (task) -> AnyObject! in
            // finished
            if task.result != nil {
                if let index = self.indexOfUploadRequest(self.newApartment.uploadRequests, uploadRequest: uploadRequest) {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.newApartment.imageUrls[index] = "https://d1mnrj0eye9ccu.cloudfront.net/\(uploadRequest.key)"
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
                        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                    })
                }
            }
            return nil
        }
    }
    func indexOfUploadRequest(array: [AWSS3TransferManagerUploadRequest?], uploadRequest: AWSS3TransferManagerUploadRequest?) -> Int? {
        for (index, object) in enumerate(array) {
            if object == uploadRequest {
                return index
            }
        }
        return nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
