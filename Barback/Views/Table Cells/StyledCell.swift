//
//  StyledCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

public class StyledCell : UITableViewCell {

    class var cellHeight: Float {
        get {
            return 60.0
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.font = UIFont(name: UIFont.primaryFont(), size: 20)
        detailTextLabel?.font = UIFont(name: UIFont.heavyFont(), size: 14)

        textLabel?.textColor = Color.Light.toUIColor()
        detailTextLabel?.textColor = Color.Lighter.toUIColor()
    }

    func highlightText(highlightedPortion: String) {
        let rangeOfFoundText = (textLabel!.text!.lowercaseString as NSString).rangeOfString(highlightedPortion.lowercaseString)

        let attributes = [NSForegroundColorAttributeName: Color.Lighter.toUIColor()]
        let boldAttributes = [NSForegroundColorAttributeName: Color.Light.toUIColor()]
        let attributedText = NSMutableAttributedString(string: textLabel!.text!, attributes: attributes)
        attributedText.setAttributes(boldAttributes, range: rangeOfFoundText)
        textLabel?.attributedText = attributedText
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}