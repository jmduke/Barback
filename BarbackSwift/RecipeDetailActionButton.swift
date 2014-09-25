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
    
    var selectedAlpha: Float?
    
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