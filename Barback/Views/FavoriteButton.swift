//
//  BezierButton.swift
//  Barback
//
//  Created by Justin Duke on 11/9/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class FavoriteButton: UIButton {

    override func drawRect(rect: CGRect) {
        let bezierPath = BezierImage.Favorite.path()


        if (self.state == UIControlState.Normal) {
            Color.Light.toUIColor().setFill()
        } else {
            Color.Tint.toUIColor().setFill()
        }
        bezierPath.fill()

        addTarget(self, action: "touch", forControlEvents: UIControlEvents.TouchUpInside)
    }

    func touch() {
        // Make the recipe's heart grow three sizes.
        UIView.animateWithDuration(0.1, delay: 0.0, options:UIViewAnimationOptions.CurveEaseIn, animations: {
                self.transform = CGAffineTransformMakeScale(1.5, 1.5)
            }, completion: {
                (success: Bool) in
                UIView.animateWithDuration(0.1, delay: 0.0, options:UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }, completion: nil)
        })
    }
}