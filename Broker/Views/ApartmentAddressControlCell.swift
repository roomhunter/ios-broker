//
//  ApartmentAddressCell.swift
//  Broker
//
//  Created by to0 on 5/10/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

protocol ApartmentAddressControlCellDelegate {
    func addressDidChangeTo(address: String)
    func apartmentNumberDidChangeTo(numberString: String)
}

class ApartmentAddressControlCell: UITableViewCell {
    
    @IBOutlet var addressLine1Field: UITextField!
    @IBOutlet var addressLine2Field: UITextField!
    @IBOutlet var cityCountryField: UITextField!
    
    @IBAction func addressDidEndEditing(sender: UITextField) {
        delegate?.addressDidChangeTo(sender.text)
    }
    
    @IBAction func apartmentNumberDidEndEditing(sender: UITextField) {
        delegate?.apartmentNumberDidChangeTo(sender.text)
    }
    var delegate: ApartmentAddressControlCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
