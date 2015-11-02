//
//  BarbackViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/25/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    func styleController() {
        navigationController?.styleController()

        tabBarController?.tabBar.translucent = false
        tabBarController?.tabBar.barTintColor = Color.Dark.toUIColor()
        tabBarController?.tabBar.tintColor = Color.Tint.toUIColor()

        view.backgroundColor = Color.Dark.toUIColor()
    }

}

extension UINavigationController {
    override func styleController() {
        navigationBar.translucent = false
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = Color.Dark.toUIColor()
        let fontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleSubheadline)
            .pointSize, 20)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: fontSize as CGFloat)!]
        let buttonFontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleCaption1)
            .pointSize, 16)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: buttonFontSize)!], forState: UIControlState.Normal)
    }
}