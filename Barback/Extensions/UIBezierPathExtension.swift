//
//  UIBezierPathExtension.swift
//  Barback
//
//  Created by Justin Duke on 11/9/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath {
    
    func toImageWithStrokeColor(strokeColor: UIColor?, fillColor: UIColor?) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width + self.lineWidth * 4, bounds.size.width + self.lineWidth * 4),
            false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, self.lineWidth, self.lineWidth)
        
        strokeColor?.setStroke()
        fillColor?.setFill()
        
        fill()
        stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}