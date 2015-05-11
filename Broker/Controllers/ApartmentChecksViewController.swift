//
//  ApartmentChecksViewController.swift
//  Broker
//
//  Created by to0 on 5/10/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ApartmentChecksViewController: UITableViewController, ApartmentSwitchCellDelegate, ApartmentTextCellDelegate {
    
    var newApartment: ApartmentModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Apartment Amenities"
        case 1:
            return "Building Facilities"
        default:
            return ""
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            return ApartmentModel.apartmentAmenitiesArray.count + 1
        case 1:
            return ApartmentModel.buildingFacilitiesArray.count + 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func switchDidChange(key: String, value: Bool, tag: Int) {
        if tag == 0 {
            newApartment.apartmentAmenitiesDict[key] = value
        }
        else {
            newApartment.buildingFacilitiesDict[key] = value
            
        }
    }
    func didEndEditingOf(key: String, value: String) {
        newApartment.additionalInfoDict[key] = value
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
        if row < ApartmentModel.apartmentAmenitiesArray.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSwitchCell", forIndexPath: indexPath) as! ApartmentSwitchCell
            cell.key = ApartmentModel.apartmentAmenitiesArray[row]
            cell.on = newApartment.apartmentAmenitiesDict[cell.key!]
            cell.tag = 0
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
            cell.key = ApartmentModel.additionalInfoArray[0]
            cell.itemTextField.text = newApartment.additionalInfoDict[cell.key!]
            cell.delegate = self
            return cell
        }
        case 1:
        if row < ApartmentModel.buildingFacilitiesArray.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentSwitchCell", forIndexPath: indexPath) as! ApartmentSwitchCell
            cell.key = ApartmentModel.buildingFacilitiesArray[row]
            cell.on = newApartment?.buildingFacilitiesDict[cell.key!]
            cell.tag = 1
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
            cell.key = ApartmentModel.additionalInfoArray[1]
            cell.itemTextField.text = newApartment.additionalInfoDict[cell.key!]
            cell.delegate = self
            return cell
        }
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentToMediaCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        default:
            return UITableViewCell()
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let aptMediaCtrl = segue.destinationViewController as! ApartmentMediaUploadViewController
        aptMediaCtrl.newApartment = newApartment
    }

}
