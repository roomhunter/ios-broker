//
//  ApartmentSwitchCell.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

protocol ApartmentSwitchCellDelegate {
    func switchDidChange(key: String, value: Bool, tag: Int)
}

class ApartmentSwitchCell: UITableViewCell {

    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var itemSwitchResult: UILabel!
    @IBOutlet var itemSwitch: UISwitch!
    @IBAction func itemSwitchChanges(sender: UISwitch) {
        on = sender.on
        if key != nil {
            delegate?.switchDidChange(key!, value: sender.on, tag:tag)
        }
    }
    var key: String? {
        didSet {
            itemLabel.text = key
        }
    }
    var on: Bool! {
        didSet {
            itemSwitch.on = on
            if on == true {
                itemSwitchResult.text = "Yes"
            }
            else {
                itemSwitchResult.text = "No"
            }
        }
    }
    var delegate: ApartmentSwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
