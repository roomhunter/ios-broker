//
//  ApartmentSubmitButtonCell.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ApartmentSubmitButtonCell: UITableViewCell {

    @IBOutlet var submitLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var state = ApartmentMediaState.NotEnough {
        didSet {
            switch state {
            case .NotEnough:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "Please upload at least 8 photos"
                activityIndicator.stopAnimating()
            case .TooMany:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "No more than 16 photos"
                activityIndicator.stopAnimating()
            case .Ready:
                submitLabel.textColor = UIColor.orangeColor()
                submitLabel.text = "Submit"
                activityIndicator.stopAnimating()
            case .Loading:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "Loading"
                activityIndicator.startAnimating()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.hidesWhenStopped = true
        // Initialization code
        state = .NotEnough
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
