//
//  UISearchBarExtension.swift
//  Barback
//
//  Created by Justin Duke on 4/14/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

extension UISearchBar {
    
    func styleSearchBar() {
        searchBarStyle = UISearchBarStyle.Minimal
        backgroundImage = UIImage()
        backgroundColor = Color.Dark.toUIColor()
        barTintColor = Color.Dark.toUIColor()
        tintColor = Color.Background.toUIColor()
    }
}