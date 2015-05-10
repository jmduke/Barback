//
//  HeaderLabel.swift
//  Barback
//
//  Created by Justin Duke on 11/18/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

public class HeaderLabel : UILabel {
    
    // It is so stupid that I need the below constructors.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        styleLabel()
    }
    
    func styleLabel() {
        textColor = Color.Dark.toUIColor()
        font = UIFont(name: UIFont.heavyFont(), size: 32)
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.5
        paragraphStyle.minimumLineHeight = 36.0
        paragraphStyle.alignment = NSTextAlignment.Center
        
        var attrString = NSMutableAttributedString(string: text!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attributedText = attrString

    }
}