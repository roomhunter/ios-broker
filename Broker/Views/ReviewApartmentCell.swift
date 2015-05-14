//
//  ReviewApartmentCell.swift
//  Broker
//
//  Created by to0 on 5/13/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ReviewApartmentCell: UITableViewCell {

    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    var status = ApartmentStatus.UnderReview {
        didSet {
            switch status {
            case .OnSale:
                statusLabel.text = "On Sale"
            case .SoldOut:
                statusLabel.text = "Sold Out"
            case .UnderReview:
                statusLabel.text = "In Review"
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
