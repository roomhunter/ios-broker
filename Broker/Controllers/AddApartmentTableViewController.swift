//
//  AddApartmentTableViewController.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit
import AssetsLibrary

class AddApartmentTableViewController: UITableViewController, UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagesActionSheet = UIActionSheet(title: "Image From", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "From Library")
    
    let imagesPicker = UIImagePickerController()
    var collectionView: UICollectionView?
    var submitButton: ApartmentSubmitButtonCell?
    var uploadRequests = [AWSS3TransferManagerUploadRequest?]()
    var aptFormDataSource: ApartmentFormDataSource?
    var imageThumbnails = [UIImage]()
    
    var apartment = ApartmentModel()
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        aptFormDataSource = ApartmentFormDataSource(addAptCtrl: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.All;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController!.tabBar.frame), 0)
        self.tableView.dataSource = aptFormDataSource
        imagesActionSheet.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagesActionSheet.addButtonWithTitle("Take Photo")
        }
        imagesPicker.delegate = self
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
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0: // from library
            imagesPicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(imagesPicker, animated: true, completion: nil)
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

            self.imageThumbnails.append(self.getThumbnailFrom(image))
            let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")

            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = NSURL(fileURLWithPath: self.getCompressedImageUrlFrom(image))
            uploadRequest.key = "apartments/\(fileName)"
            uploadRequest.bucket = "roomhunter-static"
            uploadRequest.contentType = "image/jpeg"
            uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
            
            self.uploadRequests.append(uploadRequest)
            self.apartment.imageUrls.append(nil)
            
            self.upload(uploadRequest)
            dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                self.collectionView?.reloadData()
            })
        })
        
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        // last item
        if row + 1 == collectionView.numberOfItemsInSection(0) {
            imagesActionSheet.showInView(self.tableView)
        }
    }

    // MARK: - Table view delegate


    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            if row < ApartmentModel.basicInformationArray.count  {
                // text cell
                return 44
            }
            else {
                // date picker
                return 200
            }
        case 1:
            // switch cell, apartments amenities
            return 44
        case 2:
            // switch cell, building facilities
            return 44
        case 3:
            // uploading images collection view
            return 260
        case 4:
            // submit button
            return 44
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        // last section, the submit button
        if section + 1 == tableView.numberOfSections() {
            // check all the fields
            if apartment.isComplete {
                submitButton?.status = ApartmentSubmitButtonStatus.Loading
                apartment.submit({(res: NSDictionary) in
                    submitButton?.status = ApartmentSubmitButtonStatus.Submitted

                    }, fail: {(err: NSError) in
                        self.submitButton?.status = ApartmentSubmitButtonStatus.Failed

                        let alertController = UIAlertController(title: "Failed", message: "Server Response Error", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
                            submitButton?.status = ApartmentSubmitButtonStatus.ReadyToSubmit
                        }
                        if err.code == 1000 {
                            alertController.message = "Cannot locate the address. Address shoud be in format as \"136 W 109th ST\""
                        }
                        else if err.code == 1001 {
                            alertController.message = "Price, floor, number of rooms should be NUMBERS(1,2,3) only, no LETTERS(A,B,C)"
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
                if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
                    
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.apartment.imageUrls[index] = "https://d1mnrj0eye9ccu.cloudfront.net/\(uploadRequest.key)"

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        if self.apartment.isComplete {
                            self.submitButton?.status = ApartmentSubmitButtonStatus.ReadyToSubmit
                        }
                        else {
                            self.submitButton?.status = ApartmentSubmitButtonStatus.Incomplete
                        }
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
    
    // observers for fields
    func textFieldsDidChange(sender: UITextField) {
        let tag = sender.tag

        // additional information
        if tag > 100 {
            if tag == 101 {
                apartment.additionalInfo1 = sender.text

            }
            else if tag == 102 {
                apartment.additionalInfo2 = sender.text

            }
        }
        else {
            apartment.setBasicInformationAtIndex(tag, value: sender.text)
        }
        
        if apartment.isComplete {
            submitButton?.status = ApartmentSubmitButtonStatus.ReadyToSubmit
        }
        else {
            submitButton?.status = ApartmentSubmitButtonStatus.Incomplete
        }
    }
    
    func dateDidChange(sender: UIDatePicker) {
        apartment.moveinDate = sender.date
    }
    func switchDidChange(sender: UISwitch) {
        let tag = sender.tag
        if tag / 100 == 1 {
            apartment.setApartmentAmenitiesAtIndex(tag - 100, value: sender.on)
        }
        else if tag / 100 == 2 {
            apartment.setBuildingFacilitiesAtIndex(tag - 200, value: sender.on)

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
