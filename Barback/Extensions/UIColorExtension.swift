//
//  UIColorExtension.swift
//  Barback
//
//  Created by Justin Duke on 6/14/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

enum Color: UInt {
    
    case Dark = 0x2B3A42
    case Background = 0xEFEFEF
    case Light = 0x3F5765
    case Lighter = 0x8FA7B5
    case Tint = 0xFF530D
    
    func toUIColor() -> UIColor {
        return UIColor.fromRGB(rawValue)
    }
}

extension UIColor {
    
    class func fromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}