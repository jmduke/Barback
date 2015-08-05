//
//  UIImageViewExtension.swift
//  Barback
//
//  Created by Justin Duke on 10/28/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    convenience init?(urlString: NSString) {
        let url = NSURL(string: urlString as String)
        let data = NSData(contentsOfURL: url!)
        if let data = data {
            self.init(data: data)
        } else {
            self.init()
        }
    }

    func hasImage() -> Bool {
        return CIImage != nil || CGImage != nil
    }

    func scaleDownToWidth(maxWidth: CGFloat) -> UIImage {
        let currentWidth = size.width

        if (currentWidth < maxWidth) {
            return self
        }

        let imageRatio = size.width / size.height
        let newHeight =  maxWidth / imageRatio
        let scaledSize = CGSize(width: maxWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        let scaledRect = CGRect(x: 0.0, y: 0.0, width: scaledSize.width, height: scaledSize.height)
        drawInRect(scaledRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}