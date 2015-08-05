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
            if (recipe!.garnish != "") {
                text = text! + "\nGarnish with \(recipe!.garnish.lowercaseString) "
            }
        }
    }
}