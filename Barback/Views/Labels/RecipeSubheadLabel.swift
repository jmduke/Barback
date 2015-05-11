//
//  RecipeSubheadLabel.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

public class RecipeSubheadLabel: DescriptionLabel {
    
    var recipe: Recipe? {
        didSet {
            text = "\(Int(recipe!.abv))% ABV · Served in \(recipe!.glassware) glass"
            if (recipe!.garnish != nil && recipe!.garnish != "") {
                text = text! + " · Garnish with \(recipe!.garnish!.lowercaseString) "
            }
        }
    }
}