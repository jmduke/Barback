//
//  UIColorExtension.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/14/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func darkColor() -> UIColor {
        return UIColorFromRGB(0x2B3A42)
    }
    
    func backgroundColor() -> UIColor {
        return UIColorFromRGB(0xEFEFEF)
    }
    
    func lightColor() -> UIColor {
        return UIColorFromRGB(0x3F5765)
    }
    
    func lighterColor() -> UIColor {
        return UIColorFromRGB(0x8FA7B5)
    }
    
    func tintColor() -> UIColor {
        return UIColorFromRGB(0xFF530D)
    }
}