//
//  BezierImage.swift
//  Barback
//
//  Created by Justin Duke on 4/14/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

enum BezierImage {
    case Favorited
    case Favorite
    case Glass
    case Random
    case Search

    func path() -> UIBezierPath {
        switch self {
        case .Favorited:
            let bezier2Path = UIBezierPath()
            bezier2Path.lineWidth = 0.5
            bezier2Path.moveToPoint(CGPointMake(21.43, 0))
            bezier2Path.addCurveToPoint(CGPointMake(15, 2.88), controlPoint1: CGPointMake(18.15, 0), controlPoint2: CGPointMake(16.07, 1.71))
            bezier2Path.addCurveToPoint(CGPointMake(8.57, 0), controlPoint1: CGPointMake(13.93, 1.71), controlPoint2: CGPointMake(11.85, 0))
            bezier2Path.addCurveToPoint(CGPointMake(0, 8.57), controlPoint1: CGPointMake(3.84, 0), controlPoint2: CGPointMake(0, 3.84))
            bezier2Path.addCurveToPoint(CGPointMake(15, 30), controlPoint1: CGPointMake(0, 16.36), controlPoint2: CGPointMake(12.82, 27.87))
            bezier2Path.addCurveToPoint(CGPointMake(30, 8.57), controlPoint1: CGPointMake(17.18, 27.87), controlPoint2: CGPointMake(30, 16.36))
            bezier2Path.addCurveToPoint(CGPointMake(21.43, 0), controlPoint1: CGPointMake(30, 3.84), controlPoint2: CGPointMake(26.16, 0))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(15, 27.03))
            bezier2Path.addCurveToPoint(CGPointMake(2.14, 8.57), controlPoint1: CGPointMake(4.4, 16.81), controlPoint2: CGPointMake(2.14, 11.36))
            bezier2Path.addCurveToPoint(CGPointMake(8.57, 2.14), controlPoint1: CGPointMake(2.14, 5.03), controlPoint2: CGPointMake(5.03, 2.14))
            bezier2Path.addCurveToPoint(CGPointMake(15, 6.04), controlPoint1: CGPointMake(12.1, 2.14), controlPoint2: CGPointMake(13.41, 4.44))
            bezier2Path.addCurveToPoint(CGPointMake(21.43, 2.14), controlPoint1: CGPointMake(16.59, 4.44), controlPoint2: CGPointMake(17.9, 2.14))
            bezier2Path.addCurveToPoint(CGPointMake(27.86, 8.57), controlPoint1: CGPointMake(24.97, 2.14), controlPoint2: CGPointMake(27.86, 5.03))
            bezier2Path.addCurveToPoint(CGPointMake(15, 27.03), controlPoint1: CGPointMake(27.86, 11.36), controlPoint2: CGPointMake(25.6, 16.81))
            bezier2Path.closePath()
            bezier2Path.miterLimit = 4;
            
            return bezier2Path
        case .Favorite:
            let bezierPath = UIBezierPath()
            bezierPath.lineWidth = 0.5
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
        case .Search:
            let bezier2Path = UIBezierPath()
            bezier2Path.lineWidth = 0.5
            
            bezier2Path.moveToPoint(CGPointMake(17, 18))
            bezier2Path.addLineToPoint(CGPointMake(19, 30))
            bezier2Path.addLineToPoint(CGPointMake(27, 30))
            bezier2Path.addLineToPoint(CGPointMake(29, 18))
            bezier2Path.addLineToPoint(CGPointMake(17, 18))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(25.31, 28))
            bezier2Path.addLineToPoint(CGPointMake(20.7, 28))
            bezier2Path.addLineToPoint(CGPointMake(20.03, 24))
            bezier2Path.addLineToPoint(CGPointMake(25.97, 24))
            bezier2Path.addLineToPoint(CGPointMake(25.31, 28))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(26.31, 22))
            bezier2Path.addLineToPoint(CGPointMake(19.7, 22))
            bezier2Path.addLineToPoint(CGPointMake(19.36, 20))
            bezier2Path.addLineToPoint(CGPointMake(26.64, 20))
            bezier2Path.addLineToPoint(CGPointMake(26.31, 22))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(11, 8.68))
            bezier2Path.addLineToPoint(CGPointMake(11, 0))
            bezier2Path.addLineToPoint(CGPointMake(5, 0))
            bezier2Path.addLineToPoint(CGPointMake(5, 8.68))
            bezier2Path.addCurveToPoint(CGPointMake(1, 15), controlPoint1: CGPointMake(2.64, 9.81), controlPoint2: CGPointMake(1, 12.21))
            bezier2Path.addLineToPoint(CGPointMake(1, 30))
            bezier2Path.addLineToPoint(CGPointMake(15, 30))
            bezier2Path.addLineToPoint(CGPointMake(15, 15))
            bezier2Path.addCurveToPoint(CGPointMake(11, 8.68), controlPoint1: CGPointMake(15, 12.21), controlPoint2: CGPointMake(13.36, 9.81))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(7, 2))
            bezier2Path.addLineToPoint(CGPointMake(9, 2))
            bezier2Path.addLineToPoint(CGPointMake(9, 3))
            bezier2Path.addLineToPoint(CGPointMake(7, 3))
            bezier2Path.addLineToPoint(CGPointMake(7, 2))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(13, 28))
            bezier2Path.addLineToPoint(CGPointMake(3, 28))
            bezier2Path.addLineToPoint(CGPointMake(3, 25))
            bezier2Path.addLineToPoint(CGPointMake(13, 25))
            bezier2Path.addLineToPoint(CGPointMake(13, 28))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(13, 23))
            bezier2Path.addLineToPoint(CGPointMake(3, 23))
            bezier2Path.addLineToPoint(CGPointMake(3, 17))
            bezier2Path.addLineToPoint(CGPointMake(13, 17))
            bezier2Path.addLineToPoint(CGPointMake(13, 23))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(3, 15))
            bezier2Path.addCurveToPoint(CGPointMake(7, 9.95), controlPoint1: CGPointMake(3, 12.45), controlPoint2: CGPointMake(4.69, 10.83))
            bezier2Path.addLineToPoint(CGPointMake(7, 5))
            bezier2Path.addLineToPoint(CGPointMake(9, 5))
            bezier2Path.addLineToPoint(CGPointMake(9, 9.95))
            bezier2Path.addCurveToPoint(CGPointMake(13, 15), controlPoint1: CGPointMake(11.31, 10.83), controlPoint2: CGPointMake(13, 12.45))
            bezier2Path.addLineToPoint(CGPointMake(3, 15))
            bezier2Path.closePath()
            bezier2Path.miterLimit = 4
            
            return bezier2Path
        case .Random:
            let bezier2Path = UIBezierPath()
            bezier2Path.lineWidth = 0.5
            bezier2Path.moveToPoint(CGPointMake(22, 0))
            bezier2Path.addLineToPoint(CGPointMake(8, 0))
            bezier2Path.addCurveToPoint(CGPointMake(0, 8), controlPoint1: CGPointMake(3.6, 0), controlPoint2: CGPointMake(0, 3.6))
            bezier2Path.addLineToPoint(CGPointMake(0, 22))
            bezier2Path.addCurveToPoint(CGPointMake(8, 30), controlPoint1: CGPointMake(0, 26.4), controlPoint2: CGPointMake(3.6, 30))
            bezier2Path.addLineToPoint(CGPointMake(22, 30))
            bezier2Path.addCurveToPoint(CGPointMake(30, 22), controlPoint1: CGPointMake(26.4, 30), controlPoint2: CGPointMake(30, 26.4))
            bezier2Path.addLineToPoint(CGPointMake(30, 8))
            bezier2Path.addCurveToPoint(CGPointMake(22, 0), controlPoint1: CGPointMake(30, 3.6), controlPoint2: CGPointMake(26.4, 0))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(28, 22))
            bezier2Path.addCurveToPoint(CGPointMake(22, 28), controlPoint1: CGPointMake(28, 25.31), controlPoint2: CGPointMake(25.31, 28))
            bezier2Path.addLineToPoint(CGPointMake(8, 28))
            bezier2Path.addCurveToPoint(CGPointMake(2, 22), controlPoint1: CGPointMake(4.69, 28), controlPoint2: CGPointMake(2, 25.31))
            bezier2Path.addLineToPoint(CGPointMake(2, 8))
            bezier2Path.addCurveToPoint(CGPointMake(8, 2), controlPoint1: CGPointMake(2, 4.69), controlPoint2: CGPointMake(4.69, 2))
            bezier2Path.addLineToPoint(CGPointMake(22, 2))
            bezier2Path.addCurveToPoint(CGPointMake(28, 8), controlPoint1: CGPointMake(25.31, 2), controlPoint2: CGPointMake(28, 4.69))
            bezier2Path.addLineToPoint(CGPointMake(28, 22))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(9, 4))
            bezier2Path.addCurveToPoint(CGPointMake(4, 9), controlPoint1: CGPointMake(6.24, 4), controlPoint2: CGPointMake(4, 6.24))
            bezier2Path.addCurveToPoint(CGPointMake(9, 14), controlPoint1: CGPointMake(4, 11.76), controlPoint2: CGPointMake(6.24, 14))
            bezier2Path.addCurveToPoint(CGPointMake(14, 9), controlPoint1: CGPointMake(11.76, 14), controlPoint2: CGPointMake(14, 11.76))
            bezier2Path.addCurveToPoint(CGPointMake(9, 4), controlPoint1: CGPointMake(14, 6.24), controlPoint2: CGPointMake(11.76, 4))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(9, 12))
            bezier2Path.addCurveToPoint(CGPointMake(6, 9), controlPoint1: CGPointMake(7.34, 12), controlPoint2: CGPointMake(6, 10.66))
            bezier2Path.addCurveToPoint(CGPointMake(9, 6), controlPoint1: CGPointMake(6, 7.34), controlPoint2: CGPointMake(7.34, 6))
            bezier2Path.addCurveToPoint(CGPointMake(12, 9), controlPoint1: CGPointMake(10.66, 6), controlPoint2: CGPointMake(12, 7.34))
            bezier2Path.addCurveToPoint(CGPointMake(9, 12), controlPoint1: CGPointMake(12, 10.66), controlPoint2: CGPointMake(10.66, 12))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(21, 4))
            bezier2Path.addCurveToPoint(CGPointMake(16, 9), controlPoint1: CGPointMake(18.24, 4), controlPoint2: CGPointMake(16, 6.24))
            bezier2Path.addCurveToPoint(CGPointMake(21, 14), controlPoint1: CGPointMake(16, 11.76), controlPoint2: CGPointMake(18.24, 14))
            bezier2Path.addCurveToPoint(CGPointMake(26, 9), controlPoint1: CGPointMake(23.76, 14), controlPoint2: CGPointMake(26, 11.76))
            bezier2Path.addCurveToPoint(CGPointMake(21, 4), controlPoint1: CGPointMake(26, 6.24), controlPoint2: CGPointMake(23.76, 4))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(21, 12))
            bezier2Path.addCurveToPoint(CGPointMake(18, 9), controlPoint1: CGPointMake(19.34, 12), controlPoint2: CGPointMake(18, 10.66))
            bezier2Path.addCurveToPoint(CGPointMake(21, 6), controlPoint1: CGPointMake(18, 7.34), controlPoint2: CGPointMake(19.34, 6))
            bezier2Path.addCurveToPoint(CGPointMake(24, 9), controlPoint1: CGPointMake(22.66, 6), controlPoint2: CGPointMake(24, 7.34))
            bezier2Path.addCurveToPoint(CGPointMake(21, 12), controlPoint1: CGPointMake(24, 10.66), controlPoint2: CGPointMake(22.66, 12))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(9, 16))
            bezier2Path.addCurveToPoint(CGPointMake(4, 21), controlPoint1: CGPointMake(6.24, 16), controlPoint2: CGPointMake(4, 18.24))
            bezier2Path.addCurveToPoint(CGPointMake(9, 26), controlPoint1: CGPointMake(4, 23.76), controlPoint2: CGPointMake(6.24, 26))
            bezier2Path.addCurveToPoint(CGPointMake(14, 21), controlPoint1: CGPointMake(11.76, 26), controlPoint2: CGPointMake(14, 23.76))
            bezier2Path.addCurveToPoint(CGPointMake(9, 16), controlPoint1: CGPointMake(14, 18.24), controlPoint2: CGPointMake(11.76, 16))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(9, 24))
            bezier2Path.addCurveToPoint(CGPointMake(6, 21), controlPoint1: CGPointMake(7.34, 24), controlPoint2: CGPointMake(6, 22.66))
            bezier2Path.addCurveToPoint(CGPointMake(9, 18), controlPoint1: CGPointMake(6, 19.34), controlPoint2: CGPointMake(7.34, 18))
            bezier2Path.addCurveToPoint(CGPointMake(12, 21), controlPoint1: CGPointMake(10.66, 18), controlPoint2: CGPointMake(12, 19.34))
            bezier2Path.addCurveToPoint(CGPointMake(9, 24), controlPoint1: CGPointMake(12, 22.66), controlPoint2: CGPointMake(10.66, 24))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(21, 16))
            bezier2Path.addCurveToPoint(CGPointMake(16, 21), controlPoint1: CGPointMake(18.24, 16), controlPoint2: CGPointMake(16, 18.24))
            bezier2Path.addCurveToPoint(CGPointMake(21, 26), controlPoint1: CGPointMake(16, 23.76), controlPoint2: CGPointMake(18.24, 26))
            bezier2Path.addCurveToPoint(CGPointMake(26, 21), controlPoint1: CGPointMake(23.76, 26), controlPoint2: CGPointMake(26, 23.76))
            bezier2Path.addCurveToPoint(CGPointMake(21, 16), controlPoint1: CGPointMake(26, 18.24), controlPoint2: CGPointMake(23.76, 16))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(21, 24))
            bezier2Path.addCurveToPoint(CGPointMake(18, 21), controlPoint1: CGPointMake(19.34, 24), controlPoint2: CGPointMake(18, 22.66))
            bezier2Path.addCurveToPoint(CGPointMake(21, 18), controlPoint1: CGPointMake(18, 19.34), controlPoint2: CGPointMake(19.34, 18))
            bezier2Path.addCurveToPoint(CGPointMake(24, 21), controlPoint1: CGPointMake(22.66, 18), controlPoint2: CGPointMake(24, 19.34))
            bezier2Path.addCurveToPoint(CGPointMake(21, 24), controlPoint1: CGPointMake(24, 22.66), controlPoint2: CGPointMake(22.66, 24))
            bezier2Path.closePath()
            bezier2Path.miterLimit = 4;
            
            return bezier2Path
        case .Glass:
            let bezier2Path = UIBezierPath()
            bezier2Path.lineWidth = 0.5
            bezier2Path.moveToPoint(CGPointMake(16.08, 16.91))
            bezier2Path.addLineToPoint(CGPointMake(29, 1))
            bezier2Path.addLineToPoint(CGPointMake(1, 1))
            bezier2Path.addLineToPoint(CGPointMake(13.92, 16.91))
            bezier2Path.addLineToPoint(CGPointMake(13.92, 26.85))
            bezier2Path.addLineToPoint(CGPointMake(9.62, 26.85))
            bezier2Path.addLineToPoint(CGPointMake(9.62, 29))
            bezier2Path.addLineToPoint(CGPointMake(20.38, 29))
            bezier2Path.addLineToPoint(CGPointMake(20.38, 26.85))
            bezier2Path.addLineToPoint(CGPointMake(16.08, 26.85))
            bezier2Path.addLineToPoint(CGPointMake(16.08, 16.91))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(15, 14.81))
            bezier2Path.addLineToPoint(CGPointMake(10.78, 9.62))
            bezier2Path.addLineToPoint(CGPointMake(19.22, 9.62))
            bezier2Path.addLineToPoint(CGPointMake(15, 14.81))
            bezier2Path.closePath()
            bezier2Path.moveToPoint(CGPointMake(24.47, 3.15))
            bezier2Path.addLineToPoint(CGPointMake(20.97, 7.46))
            bezier2Path.addLineToPoint(CGPointMake(9.03, 7.46))
            bezier2Path.addLineToPoint(CGPointMake(5.53, 3.15))
            bezier2Path.addLineToPoint(CGPointMake(24.47, 3.15))
            bezier2Path.closePath()
            bezier2Path.miterLimit = 4;
            
            return bezier2Path
        }
    }
}