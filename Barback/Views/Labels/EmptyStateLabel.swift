//
//  EmptyStateLabel.swift
//  Barback
//
//  Created by Justin Duke on 11/18/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class EmptyStateLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textAlignment = NSTextAlignment.Center
        textColor = Color.Lighter.toUIColor()
        numberOfLines = 3
        font = UIFont(name: UIFont.primaryFont(), size: 24)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}