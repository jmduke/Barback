//
//  SimpleButton.swift
//  Barback
//
//  Created by Justin Duke on 12/14/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class SimpleButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleButton()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleButton()
    }
    
    func styleButton() {
        tintColor = Color.Tint.toUIColor()
        titleLabel!.font = UIFont(name: UIFont.heavyFont(), size: 20)
        userInteractionEnabled = true
    }
    
}