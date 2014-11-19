//
//  HeaderLabel.swift
//  Barback
//
//  Created by Justin Duke on 11/18/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class HeaderLabel : UILabel {
    
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
        textColor = UIColor.darkColor()
        font = UIFont(name: UIFont.heavyFont(), size: 32)
        textAlignment = NSTextAlignment.Center
    }
}