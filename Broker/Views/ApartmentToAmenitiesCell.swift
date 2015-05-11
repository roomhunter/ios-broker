//
//  ApartmentToAmenitiesCell.swift
//  Broker
//
//  Created by to0 on 5/10/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit


class ApartmentToAmenitiesCell: UITableViewCell {

    @IBOutlet var stateLabel: UILabel!
    var state = ApartmentInformationState.Incomplete {
        didSet {
            switch state {
            case .AddressIncorrect:
                stateLabel.text = "Address should be in format as \"136 W 109TH ST\""
                stateLabel.textColor = UIColor.lightGrayColor()
                self.userInteractionEnabled = false
            case .Incomplete:
                stateLabel.text = "Please complete all fields"
                stateLabel.textColor = UIColor.lightGrayColor()
                self.userInteractionEnabled = false
            case .ShouldBeNumbers:
                stateLabel.text = "Price, floor, rooms shoud be in numbers only"
                stateLabel.textColor = UIColor.lightGrayColor()
                self.userInteractionEnabled = false
            case .Ready:
                stateLabel.text = "Next Step"
                stateLabel.textColor = self.tintColor
                self.userInteractionEnabled = true
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        state = .Incomplete
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
