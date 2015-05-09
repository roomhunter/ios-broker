//
//  UploadingImageCell.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class UploadingImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!
    var progress: Float = 0.0 {
        didSet {
            if progress >= 0.0 && progress < 1.0 {
                statusLabel.text = "Uploading"
                progressView.progress = progress
            }
            else if progress == 1.0 {
                statusLabel.text = "Uploaded"
                progressView.progress = 1.0
            }
            else if progress < 0.0 {
                statusLabel.text = "Failed"
                progressView.progress = 0.0
            }
        }
    }
    
}
