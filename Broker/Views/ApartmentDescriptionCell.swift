//
//  ApartmentDescriptionCell.swift
//  Broker
//
//  Created by to0 on 5/27/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class ApartmentDescriptionCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet var textView: UITextView!
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGrayColor()
        }
        delegate?.didEndEditingOf(key!, value: textView.text)
    }
    var delegate: ApartmentTextCellDelegate?
    var keyboardType = UIKeyboardType.Default {
        didSet {
            textView.keyboardType = keyboardType
        }
    }
    var key: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
        textView.text = "Description"
        textView.textColor = UIColor.lightGrayColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
