//
//  DescriptionTextView.swift
//  Barback
//
//  Created by Justin Duke on 11/28/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class DescriptionTextView : UITextView {
    
    var markdownText: NSString? {
        didSet {
            let parser = NSAttributedStringMarkdownParser()
            parser.paragraphFont = font
            parser.italicFontName = UIFont.heavyFont()
            attributedText = parser.attributedStringFromMarkdownString(markdownText!)
            textAlignment = NSTextAlignment.Center
            textColor = Color.Light.toUIColor()
        }
    }
    
    override init() {
        super.init()
        styleLabel()
        
    }
    
    // It is so stupid that I need the below constructors.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func styleLabel() {
        font = UIFont(name: UIFont.primaryFont(), size: 15)
        textAlignment = NSTextAlignment.Center
        textColor = Color.Light.toUIColor()
        backgroundColor = Color.Background.toUIColor()
        tintColor = Color.Tint.toUIColor()
    }
}