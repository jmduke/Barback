//
//  IngredientSubheadLabel.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

public class IngredientSubheadLabel: DescriptionLabel {
    
    var ingredient: IngredientBase? {
        didSet {
            text = Int(ingredient!.abv) > 0 ? "\(ingredient!.abv)% ABV" : "(non-alcoholic)"
        }
    }
}