//
//  ApartmentSubmitButtonCell.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

enum ApartmentSubmitButtonStatus: Int {
    case Incomplete
    case ReadyToSubmit
    case Loading
    case Submitted
    case Failed
}

class ApartmentSubmitButtonCell: UITableViewCell {

    @IBOutlet var submitLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var status = ApartmentSubmitButtonStatus.Incomplete {
        didSet {
            switch status {
            case .Incomplete:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "Please Complete The Form"
                activityIndicator.stopAnimating()
            case .ReadyToSubmit:
                submitLabel.textColor = UIColor.orangeColor()
                submitLabel.text = "Submit"
                activityIndicator.stopAnimating()
            case .Loading:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "Loading"
                activityIndicator.startAnimating()
            case .Submitted:
                submitLabel.textColor = UIColor.orangeColor()
                submitLabel.text = "Submitted"
                activityIndicator.stopAnimating()
            case .Failed:
                submitLabel.textColor = UIColor.lightGrayColor()
                submitLabel.text = "Failed"
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.hidesWhenStopped = true
        status = ApartmentSubmitButtonStatus.Incomplete
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
