//
//  ApartmentTexCell.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

protocol ApartmentTextCellDelegate {
    func didEndEditingOf(key: String, value: String)
}
class ApartmentTextCell: UITableViewCell {

    @IBOutlet var itemTextField: UITextField!
    
    // loose coupling
    @IBAction func textFieldDidEndEditing(sender: UITextField) {
        if key != nil {
            delegate?.didEndEditingOf(key!, value: itemTextField.text)
        }
    }
    var delegate: ApartmentTextCellDelegate?
    var keyboardType: UIKeyboardType = UIKeyboardType.Default {
        didSet {
            itemTextField.keyboardType = keyboardType
        }
    }
    var key: String? {
        didSet {
            self.itemTextField.placeholder = key
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
