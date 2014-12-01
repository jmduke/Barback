//
//  StyledCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class StyledCell : UITableViewCell {
    
    class var cellHeight: Float {
        get {
            return 60.0
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = UIFont(name: UIFont.primaryFont(), size: 20)
        detailTextLabel?.font = UIFont(name: UIFont.heavyFont(), size: 14)
        
        textLabel?.textColor = Color.Light.toUIColor()
        detailTextLabel?.textColor = Color.Lighter.toUIColor()
        
        if (textLabel?.text == "Bartender's Choice" || textLabel?.text == "Shopping List") {
            textLabel?.textColor = Color.Tint.toUIColor()
            detailTextLabel?.textColor = Color.Tint.toUIColor()
        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}