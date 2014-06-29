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
        self.textLabel.font = UIFont(name: UIFont().primaryFont(), size: 20)
        self.detailTextLabel.font = UIFont(name: UIFont().heavyFont(), size: 14)
        
        self.textLabel.textColor = UIColor().lightColor()
        self.detailTextLabel.textColor = UIColor().lighterColor()
        
        if (self.textLabel.text == "Bartender's Choice" || self.textLabel.text == "Shopping List") {
            self.textLabel.textColor = UIColor().tintColor()
        }
    }
    
}