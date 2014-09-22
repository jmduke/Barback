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
    
    override var selected: Bool {
        didSet {
            alpha = selected ? 0.5 : 1
        }
    }
    
}