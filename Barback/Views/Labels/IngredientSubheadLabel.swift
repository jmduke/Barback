//
//  IngredientSubheadLabel.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

public class IngredientSubheadLabel: DescriptionLabel {

    public var ingredient: IngredientBase? {
        didSet {
            if Int(ingredient!.abv) > 0 {
                text = "A \(ingredient!.ingredientType.rawValue) with \(ingredient!.abv)% ABV"
            } else {
                text = "A non-alcoholic \(ingredient!.ingredientType.rawValue)"
            }
        }
    }
}