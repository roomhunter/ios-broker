//
//  AddApartmentTableViewController.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit
import AssetsLibrary

class AddApartmentTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagesActionSheet = UIActionSheet(title: "Image From", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "From Library")
    
    let imagesPicker = UIImagePickerController()
    var collectionView: UICollectionView?
    var submitButton: ApartmentSubmitButtonCell?
    var uploadRequests = [AWSS3TransferManagerUploadRequest?]()
    var uploadFileURLs = [NSURL?]()
    
    var apartment = Apartment()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.All;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController!.tabBar.frame), 0)
        
        imagesActionSheet.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagesActionSheet.addButtonWithTitle("Take Photo")
        }
        imagesPicker.allowsEditing = true
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
        case 1: // form camera
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
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".png")
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("upload").stringByAppendingPathComponent(fileName)
        let imageData = UIImagePNGRepresentation(image)
        imageData.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = NSURL(fileURLWithPath: filePath)
        uploadRequest.key = "apartments/\(fileName)"
        uploadRequest.bucket = "roomhunter-static"
        uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
        
        uploadRequests.append(uploadRequest)
        apartment.images.append(nil)
        
        upload(uploadRequest)
        collectionView?.reloadData()
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploadRequests.count + 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UploadingImageCell", forIndexPath: indexPath) as! UploadingImageCell
        
        let row = indexPath.row
        
        if row == uploadRequests.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddImageButtonCell", forIndexPath: indexPath) as! UICollectionViewCell
            return cell
        }
        
        if let uploadRequest = self.uploadRequests[row] {
            if let data = NSData(contentsOfURL: uploadRequest.body) {
                cell.imageView.image = UIImage(data: data)
            }
            switch uploadRequest.state {
            case .Running:
//                if let data = NSData(contentsOfURL: uploadRequest.body) {
//                    cell.imageView.image = UIImage(data: data)
//                }
                uploadRequest.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if totalBytesExpectedToSend > 0 {
                            cell.progress = Float(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
                        }
                    })
                }
                
            case .Completed:
                cell.progress = 1.0
                
                
            default:
                cell.imageView.image = nil
                cell.progress = -1.0
            }
        }
//        if let downloadFileURL = self.apartment.images[indexPath.row] {
//            cell.progress = 1.0
//        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        // last item
        if row + 1 == collectionView.numberOfItemsInSection(0) {
            
            imagesActionSheet.showInView(self.tableView)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            // + 1 is the move in date cell
            return Apartment.basicInformationArray.count + 1
        case 1:
            // + 1 is the additional description
            return Apartment.apartmentAmenitiesArray.count + 1
        case 2:
            // + 1 is the additional description
            return Apartment.buildingFacilitiesArray.count + 1
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Basic Information"
        case 1:
            return "Apartment Amenities"
        case 2:
            return "Building Facilities"
        case 3:
            return "Apartment Images"
        default:
            return ""
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            if row < Apartment.basicInformationArray.count  {
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

                        let alertController = UIAlertController(title: "Failed", message: "Submit Error", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        self.presentViewController(alertController, animated: true) {
                            
                        }
                })

            }
            
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            if row < Apartment.basicInformationArray.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
                cell.itemTextField.placeholder = Apartment.basicInformationArray[row]
                if row > 1 {
                    cell.keyboardType = UIKeyboardType.NumberPad
                }
                else {
                    cell.keyboardType = UIKeyboardType.ASCIICapable
                }
                cell.itemTextField.text = apartment.getBasicInformationAtIndex(row)
                cell.itemTextField.tag = row
                cell.itemTextField.addTarget(self, action: "textFieldsDidChange:", forControlEvents: UIControlEvents.EditingDidEnd)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentDateCell", forIndexPath: indexPath) as! ApartmentDateCell
                cell.moveinDate = apartment.moveinDate
                cell.datePicker.addTarget(self, action: "dateDidChange:", forControlEvents: UIControlEvents.ValueChanged)
                return cell
            }
            
        case 1:
            if row < Apartment.apartmentAmenitiesArray.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSwitchCell", forIndexPath: indexPath) as! ApartmentSwitchCell
                cell.itemLabel.text = Apartment.apartmentAmenitiesArray[row]
                cell.itemSwitch.tag = row + 100
                cell.on = apartment.getApartmentAmenitiesAtIndex(row)
                cell.itemSwitch.addTarget(self, action: "switchDidChange:", forControlEvents: UIControlEvents.ValueChanged)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
                cell.itemTextField.placeholder = "Additional Info for room amenities"
                cell.itemTextField.text = apartment.additionalInfo1
                cell.itemTextField.tag = 101
                cell.keyboardType = UIKeyboardType.ASCIICapable
                cell.itemTextField.addTarget(self, action: "textFieldsDidChange:", forControlEvents: UIControlEvents.EditingDidEnd)
                return cell
            }
        case 2:
            if row < Apartment.buildingFacilitiesArray.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSwitchCell", forIndexPath: indexPath) as! ApartmentSwitchCell
                cell.itemLabel.text = Apartment.buildingFacilitiesArray[row]
                cell.itemSwitch.tag = row + 200
                cell.on = apartment.getBuildingFacilitiesAtIndex(row)
                cell.itemSwitch.addTarget(self, action: "switchDidChange:", forControlEvents: UIControlEvents.ValueChanged)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
                cell.itemTextField.placeholder = "Additional Info for building facilities"
                cell.itemTextField.text = apartment.additionalInfo2
                cell.itemTextField.tag = 102
                cell.keyboardType = UIKeyboardType.ASCIICapable
                cell.itemTextField.addTarget(self, action: "textFieldsDidChange:", forControlEvents: UIControlEvents.EditingDidEnd)

                return cell
            }
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentImagesCell", forIndexPath: indexPath) as! ApartmentImagesCell
            cell.imagesCollectionView.dataSource = self
            cell.imagesCollectionView.delegate = self
            collectionView = cell.imagesCollectionView
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSubmitButtonCell", forIndexPath: indexPath) as! ApartmentSubmitButtonCell
            submitButton = cell
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if task.result != nil {
                if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
                    self.apartment.images[index] = "https://d1mnrj0eye9ccu.cloudfront.net/\(uploadRequest.key)"
                    if self.apartment.isComplete {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            submitButton?.status = ApartmentSubmitButtonStatus.ReadyToSubmit
                        })
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            submitButton?.status = ApartmentSubmitButtonStatus.Incomplete
                        })
                    }
                    
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
