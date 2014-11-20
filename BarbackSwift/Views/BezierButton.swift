//
//  BezierButton.swift
//  Barback
//
//  Created by Justin Duke on 11/9/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class BezierButton: UIButton {
    
    override func drawRect(rect: CGRect) {
        var bezierPath = UIBezierPath.favoriteButton()

        
        if (self.state == UIControlState.Normal) {
            UIColor.lighterColor().setFill()
        } else {
            UIColor.tintColor().setFill()
        }
        bezierPath.fill()

    }
}