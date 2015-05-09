//
//  ApartmentFormDataSource.swift
//  Broker
//
//  Created by to0 on 5/9/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ApartmentFormDataSource: NSObject, UITableViewDataSource, UICollectionViewDataSource {
    
    unowned let addAptCtrl: AddApartmentTableViewController
    
    init(addAptCtrl: AddApartmentTableViewController) {
        self.addAptCtrl = addAptCtrl
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addAptCtrl.uploadRequests.count + 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UploadingImageCell", forIndexPath: indexPath) as! UploadingImageCell
        
        let row = indexPath.row
        
        if row == addAptCtrl.uploadRequests.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddImageButtonCell", forIndexPath: indexPath) as! UICollectionViewCell
            return cell
        }
        
        if let uploadRequest = addAptCtrl.uploadRequests[row] {
            if let data = NSData(contentsOfURL: uploadRequest.body) {
                cell.imageView.image = UIImage(data: data)
            }
            switch uploadRequest.state {
            case .Running:
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
        
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // + 1 is the move in date cell
            return ApartmentModel.basicInformationArray.count + 1
        case 1:
            // + 1 is the additional description
            return ApartmentModel.apartmentAmenitiesArray.count + 1
        case 2:
            // + 1 is the additional description
            return ApartmentModel.buildingFacilitiesArray.count + 1
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            if row < ApartmentModel.basicInformationArray.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
                cell.itemTextField.placeholder = ApartmentModel.basicInformationArray[row]
                if row > 1 {
                    cell.keyboardType = UIKeyboardType.NumberPad
                }
                else {
                    cell.keyboardType = UIKeyboardType.ASCIICapable
                }
                cell.itemTextField.text = addAptCtrl.apartment.getBasicInformationAtIndex(row)
                cell.itemTextField.tag = row
                cell.itemTextField.addTarget(self, action: "textFieldsDidChange:", forControlEvents: UIControlEvents.EditingDidEnd)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentDateCell", forIndexPath: indexPath) as! ApartmentDateCell
                cell.moveinDate = addAptCtrl.apartment.moveinDate
                cell.datePicker.addTarget(self, action: "dateDidChange:", forControlEvents: UIControlEvents.ValueChanged)
                return cell
            }
            
        case 1:
            if row < ApartmentModel.apartmentAmenitiesArray.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSwitchCell", forIndexPath: indexPath) as! ApartmentSwitchCell
                cell.itemLabel.text = ApartmentModel.apartmentAmenitiesArray[row]
                cell.itemSwitch.tag = row + 100
                cell.on = addAptCtrl.apartment.getApartmentAmenitiesAtIndex(row)
                cell.itemSwitch.addTarget(self, action: "switchDidChange:", forControlEvents: UIControlEvents.ValueChanged)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
                cell.itemTextField.placeholder = "Additional Info for room amenities"
                cell.itemTextField.text = addAptCtrl.apartment.additionalInfo1
                cell.itemTextField.tag = 101
                cell.keyboardType = UIKeyboardType.ASCIICapable
                cell.itemTextField.addTarget(self, action: "textFieldsDidChange:", forControlEvents: UIControlEvents.EditingDidEnd)
                return cell
            }
        case 2:
            if row < ApartmentModel.buildingFacilitiesArray.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSwitchCell", forIndexPath: indexPath) as! ApartmentSwitchCell
                cell.itemLabel.text = ApartmentModel.buildingFacilitiesArray[row]
                cell.itemSwitch.tag = row + 200
                cell.on = addAptCtrl.apartment.getBuildingFacilitiesAtIndex(row)
                cell.itemSwitch.addTarget(self, action: "switchDidChange:", forControlEvents: UIControlEvents.ValueChanged)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
                cell.itemTextField.placeholder = "Additional Info for building facilities"
                cell.itemTextField.text = addAptCtrl.apartment.additionalInfo2
                cell.itemTextField.tag = 102
                cell.keyboardType = UIKeyboardType.ASCIICapable
                cell.itemTextField.addTarget(self, action: "textFieldsDidChange:", forControlEvents: UIControlEvents.EditingDidEnd)
                
                return cell
            }
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentImagesCell", forIndexPath: indexPath) as! ApartmentImagesCell
            cell.imagesCollectionView.dataSource = self
            cell.imagesCollectionView.delegate = addAptCtrl
            addAptCtrl.collectionView = cell.imagesCollectionView
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSubmitButtonCell", forIndexPath: indexPath) as! ApartmentSubmitButtonCell
            addAptCtrl.submitButton = cell
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}
