//
//  SegmentControl.swift
//  Barback
//
//  Created by Justin Duke on 5/19/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class SegmentControl: UISegmentedControl {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.whiteColor()
        tintColor = Color.Light.toUIColor()
        let fontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleSubheadline)
            .pointSize, 20)
        setTitleTextAttributes([NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: fontSize)!], forState: UIControlState.Normal)
        addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 240))

        layer.borderColor = Color.Dark.toUIColor().CGColor
        layer.borderWidth = 1.0
    }
}