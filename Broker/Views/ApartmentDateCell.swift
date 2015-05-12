//
//  ApartmentDateCell.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

protocol ApartmentDateCellDelegate {
    func didChangeDate(date: NSDate)
}
class ApartmentDateCell: UITableViewCell {


    @IBOutlet var datePicker: UIDatePicker!
    @IBAction func datePickerChanged(sender: UIDatePicker) {
//        moveinDate = sender.date
        delegate?.didChangeDate(sender.date)
    }
    var delegate: ApartmentDateCellDelegate?
//    var moveinDate = NSDate() {
//        didSet {
//            datePicker.date = moveinDate
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
