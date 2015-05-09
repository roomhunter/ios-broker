//
//  ApartmentDateCell.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ApartmentDateCell: UITableViewCell {

    let dateFormatter = NSDateFormatter()

    @IBOutlet var dateSelectedLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        moveinDate = sender.date
    }
    
    var moveinDate = NSDate() {
        didSet {
            dateSelectedLabel.text = "Move-in Date: \(dateFormatter.stringFromDate(moveinDate))"
            datePicker.date = moveinDate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
