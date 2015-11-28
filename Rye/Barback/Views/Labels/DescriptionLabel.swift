//
//  DescriptionLabel.swift
//  Barback
//
//  Created by Justin Duke on 11/18/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

public class DescriptionLabel : UILabel {

    // It is so stupid that I need the below constructors.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        styleLabel()
    }

    func styleLabel() {
        let fontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleCaption1)
            .pointSize, 16)
        font = UIFont(name: UIFont.heavyFont(), size: fontSize)
        textAlignment = NSTextAlignment.Center
        
        textColor = Color.Light.toUIColor()
        backgroundColor = Color.Background.toUIColor()
    }
}