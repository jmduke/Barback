//
//  SimpleButton.swift
//  Barback
//
//  Created by Justin Duke on 12/14/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class SimpleButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = Color.Tint.toUIColor()
        titleLabel!.font = UIFont(name: UIFont.primaryFont(), size: 16)
        userInteractionEnabled = true
    }
    
}