//
//  UIImageViewExtension.swift
//  Barback
//
//  Created by Justin Duke on 10/28/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

extension UIImage {
    
    convenience init?(url: NSString) {
        self.init(data: NSData(contentsOfURL: NSURL(string: url)!)!)
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