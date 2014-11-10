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
    class func favoriteButton() -> UIBezierPath {
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(11.21, 21.28))
        bezierPath.addCurveToPoint(CGPointMake(8.82, 18.91), controlPoint1: CGPointMake(10.78, 20.74), controlPoint2: CGPointMake(9.71, 19.67))
        bezierPath.addCurveToPoint(CGPointMake(4.79, 15.23), controlPoint1: CGPointMake(6.21, 16.66), controlPoint2: CGPointMake(5.85, 16.34))
        bezierPath.addCurveToPoint(CGPointMake(2, 8.33), controlPoint1: CGPointMake(2.83, 13.18), controlPoint2: CGPointMake(2, 11.12))
        bezierPath.addCurveToPoint(CGPointMake(2.42, 5.64), controlPoint1: CGPointMake(2, 6.97), controlPoint2: CGPointMake(2.08, 6.44))
        bezierPath.addCurveToPoint(CGPointMake(4.9, 2.64), controlPoint1: CGPointMake(2.99, 4.28), controlPoint2: CGPointMake(3.83, 3.26))
        bezierPath.addCurveToPoint(CGPointMake(7.31, 2), controlPoint1: CGPointMake(5.66, 2.21), controlPoint2: CGPointMake(6.04, 2.01))
        bezierPath.addCurveToPoint(CGPointMake(9.69, 2.66), controlPoint1: CGPointMake(8.63, 1.99), controlPoint2: CGPointMake(8.91, 2.17))
        bezierPath.addCurveToPoint(CGPointMake(11.83, 5.42), controlPoint1: CGPointMake(10.65, 3.25), controlPoint2: CGPointMake(11.62, 4.52))
        bezierPath.addLineToPoint(CGPointMake(11.95, 5.98))
        bezierPath.addLineToPoint(CGPointMake(12.26, 5.21))
        bezierPath.addCurveToPoint(CGPointMake(21.49, 5.32), controlPoint1: CGPointMake(14, 0.88), controlPoint2: CGPointMake(19.56, 0.94))
        bezierPath.addCurveToPoint(CGPointMake(21.63, 11.34), controlPoint1: CGPointMake(22.11, 6.7), controlPoint2: CGPointMake(22.18, 9.67))
        bezierPath.addCurveToPoint(CGPointMake(16.51, 17.71), controlPoint1: CGPointMake(20.92, 13.51), controlPoint2: CGPointMake(19.59, 15.17))
        bezierPath.addCurveToPoint(CGPointMake(12.04, 22.26), controlPoint1: CGPointMake(14.48, 19.38), controlPoint2: CGPointMake(12.2, 21.9))
        bezierPath.addCurveToPoint(CGPointMake(11.21, 21.28), controlPoint1: CGPointMake(11.85, 22.67), controlPoint2: CGPointMake(12.03, 22.32))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        return bezierPath
    }
}