//
//  AddApartmentTableViewController.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit
import AssetsLibrary

class ApartmentInfomationTableViewController: UITableViewController, ApartmentTextCellDelegate, ApartmentDateCellDelegate, ApartmentAddressControlCellDelegate {
    
    // we start edit it from here
    var newApartment = ApartmentModel()
    var nextCell: ApartmentToAmenitiesCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if newApartment.renewed == true {
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // address section, address control, line 1, line 2, city
            return 1
        case 1:
            // + 1 is the move in date cell
            return ApartmentModel.basicInformationArray.count
        case 2:
            // date cell
            return 1
        case 3:
            // next page
            return 1
        default:
            return 0
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentAddressControlCell", forIndexPath: indexPath) as! ApartmentAddressControlCell
            cell.delegate = self
            cell.addressLine1Field.text = newApartment.addressLine1
            cell.addressLine2Field.text = newApartment.addressLine2
            cell.cityCountryField.text = newApartment.cityCountryString
            return cell
        case 1:
            
            if row > 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentTextCell", forIndexPath: indexPath) as! ApartmentTextCell
                cell.key = ApartmentModel.basicInformationArray[row]
                if cell.key == "How Many Bathrooms" {
                    cell.keyboardType = UIKeyboardType.NumbersAndPunctuation
                }
                else {
                    cell.keyboardType = UIKeyboardType.NumberPad
                }
                cell.itemTextField.text = newApartment.basicInformationDict[cell.key!]
                cell.delegate = self
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentDescriptionCell", forIndexPath: indexPath) as! ApartmentDescriptionCell
                cell.key = ApartmentModel.basicInformationArray[row]
                cell.delegate = self
                cell.keyboardType = UIKeyboardType.Default
                return cell
            }
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentDateCell", forIndexPath: indexPath) as! ApartmentDateCell
            cell.datePicker.date = self.newApartment.moveinDate
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("ApartmentToAmenitiesCell", forIndexPath: indexPath) as! ApartmentToAmenitiesCell
            nextCell = cell
            cell.state = newApartment.informationState
            return cell
            
        default:
            return UITableViewCell()
        }
    }


    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            // address
            return 132
        case 1:
            // switch cell, apartments amenities
            if row == 0 {
                return 132
            }
            return 44
        case 2:
            // date
            return 200
        case 3:
            return 44
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Address"
        case 1:
            return "Basic Information"
        case 2:
            return "Move-in Date: \(newApartment.moveinDateString)"
        default:
            return nil
        }
    }
    
    // delegates
    func addressDidChangeTo(address: String) {
        newApartment.convertAddressString(address, success: { [unowned self] in
            dispatch_async(dispatch_get_main_queue(), {
                let firstRow = NSIndexPath(forRow: 0, inSection: 0)
                let lastRow = NSIndexPath(forRow: 0, inSection: 3)
                self.tableView.reloadRowsAtIndexPaths([firstRow, lastRow], withRowAnimation: UITableViewRowAnimation.Fade)
            })
        })
    }
    
    func apartmentNumberDidChangeTo(numberString: String) {
        newApartment.addressLine2 = numberString
    }
    
    func didEndEditingOf(key: String, value: String) {
        newApartment.basicInformationDict[key] = value
        let lastRow = NSIndexPath(forRow: 0, inSection: 3)
        self.tableView.reloadRowsAtIndexPaths([lastRow], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func didChangeDate(date: NSDate) {
        newApartment.moveinDate = date
        // move in date view
        tableView.headerViewForSection(2)?.textLabel.text = "Move-in Date: \(newApartment.moveinDateString)".uppercaseString
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let aptCheckCtrl = segue.destinationViewController as! ApartmentChecksViewController
        self.tableView.endEditing(true)
        aptCheckCtrl.newApartment = newApartment
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

}
