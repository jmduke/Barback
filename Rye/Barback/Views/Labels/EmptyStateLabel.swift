//
//  EmptyStateLabel.swift
//  Barback
//
//  Created by Justin Duke on 11/18/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class EmptyStateLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        styleLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        styleLabel()
    }

    func styleLabel() {
        textAlignment = NSTextAlignment.Center
        textColor = Color.Lighter.toUIColor()
        numberOfLines = 6
        let fontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleHeadline)
            .pointSize, 24)
        font = UIFont(name: UIFont.primaryFont(), size: fontSize)
    }
}