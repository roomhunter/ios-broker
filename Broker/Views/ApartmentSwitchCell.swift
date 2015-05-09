//
//  ApartmentSwitchCell.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ApartmentSwitchCell: UITableViewCell {

    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var itemSwitchResult: UILabel!
    @IBOutlet var itemSwitch: UISwitch!
    @IBAction func itemSwitchChanges(sender: UISwitch) {
        on = sender.on
    }
    var on = false {
        didSet {
            itemSwitch.on = on
            if on {
                itemSwitchResult.text = "YES"
            }
            else {
                itemSwitchResult.text = "NO"
            }
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
