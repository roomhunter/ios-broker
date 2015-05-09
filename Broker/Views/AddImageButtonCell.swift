//
//  AddImageButtonCell.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class AddImageButtonCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1
        self.layer.borderColor = self.tintColor.CGColor
//        self.backgroundColor = UIColor.blueColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 1
        self.layer.borderColor = self.tintColor.CGColor
//        self.backgroundColor = UIColor.blueColor()
    }
}
