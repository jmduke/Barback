//
//  UISearchBarExtension.swift
//  Barback
//
//  Created by Justin Duke on 4/14/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {

    func styleSearchBar() {
        searchBarStyle = UISearchBarStyle.Minimal
        backgroundImage = UIImage()
        backgroundColor = Color.Dark.toUIColor()
        barTintColor = Color.Dark.toUIColor()
        tintColor = Color.Background.toUIColor()
        
        for subview in self.subviews as [UIView] {
            for nestedSubview in subview.subviews as [UIView] {
                if nestedSubview.isKindOfClass(UITextField) {
                    let textField = nestedSubview as! UITextField
                    textField.textColor = UIColor.whiteColor()
                }
            }
        }
    }
}