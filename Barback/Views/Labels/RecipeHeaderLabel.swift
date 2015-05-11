//
//  RecipeHeaderLabel.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

public class RecipeHeaderLabel: HeaderLabel {
    
    var recipe: Recipe? {
        didSet {
            text = recipe!.name
            styleLabel()
        }
    }
}