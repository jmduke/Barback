//
//  UITableViewCellExtension.swift
//  Barback
//
//  Created by Justin Duke on 6/29/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    
    func stylePrimary() {
        textLabel?.font = UIFont(name: UIFont.primaryFont(), size: 20)
        detailTextLabel?.font = UIFont(name: UIFont.heavyFont(), size: 14)
        
        textLabel?.textColor = UIColor.lightColor()
        detailTextLabel?.textColor = UIColor.lighterColor()
        
        if (textLabel?.text == "Bartender's Choice" || textLabel?.text == "Shopping List") {
            textLabel?.textColor = UIColor.tintColor()
            detailTextLabel?.textColor = UIColor.tintColor()
        }

        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
    
    func primaryCellHeight() -> Float {
        return 60
    }
    
}