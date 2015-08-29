//
//  SimpleButton.swift
//  Barback
//
//  Created by Justin Duke on 12/14/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

public class SimpleButton : UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        styleButton()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        styleButton()
    }

    func styleButton() {
        tintColor = Color.Tint.toUIColor()
        let fontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleSubheadline)
            .pointSize, 20)
        titleLabel!.font = UIFont(name: UIFont.heavyFont(), size: fontSize)
        userInteractionEnabled = true
    }

}