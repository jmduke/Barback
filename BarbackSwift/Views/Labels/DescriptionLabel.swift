//
//  DescriptionLabel.swift
//  Barback
//
//  Created by Justin Duke on 11/18/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class DescriptionLabel : UILabel {
    
    var markdownText: NSString? {
        didSet {
            if markdownText == nil || markdownText == "" {
                attributedText = NSAttributedString(string: "")
                return
            }
            
            var markdownEngine = Markdown()
            let hexColor = NSString(format:"%2X", Color.Light.rawValue)
            var informationHTML = "<style type='text/css'>"
                + "p { text-align: center;"
                + "    font-family: \(font.familyName);"
                + "    font-size: \(font.pointSize)px;"
                + "    color: \(hexColor); }"
                + "</style>"
            informationHTML += markdownEngine.transform(markdownText!)
            let informationData = informationHTML.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            let informationString = NSAttributedString(data: informationData!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
            attributedText = informationString
            
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
    
    func styleLabel() {
        font = UIFont(name: UIFont.heavyFont(), size: 15)
        textAlignment = NSTextAlignment.Center
        textColor = Color.Light.toUIColor()
    }
}