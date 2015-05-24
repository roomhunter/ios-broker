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
                submitLabel.text = "Please upload at least 4 photos"
                activityIndicator.stopAnimating()
                self.userInteractionEnabled = false
            case .TooMany:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "No more than 16 photos"
                activityIndicator.stopAnimating()
                self.userInteractionEnabled = false
            case .SelectCover:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "Select One as Cover Photo"
                activityIndicator.stopAnimating()
                self.userInteractionEnabled = false
            case .Ready:
                submitLabel.textColor = UIColor.orangeColor()
                submitLabel.text = "Submit"
                activityIndicator.stopAnimating()
                self.userInteractionEnabled = true
            case .Loading:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "Loading"
                activityIndicator.startAnimating()
                self.setSelected(false, animated: true)
                self.userInteractionEnabled = false
            case .Success:
                submitLabel.textColor = self.tintColor
                submitLabel.text = "Success, Upload A New One!"
                activityIndicator.stopAnimating()
                self.userInteractionEnabled = false
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
