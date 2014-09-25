//
//  RecipeDetailActionButton.swift
//  Barback
//
//  Created by Justin Duke on 9/21/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import UIKit
import Foundation

class RecipeDetailActionButton: UIButton {
    
    // Denotes the transparency of the object when it has been selected.
    var selectedAlpha: Float?
    
    // Denotes the action to occur when button is pressed.
    func setAction(delegate: AnyObject, action: Selector) {
        addTarget(delegate, action: action, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                alpha = CGFloat(selectedAlpha ?? 0.5)
            } else {
                alpha = 1
            }
        }
    }
    
}