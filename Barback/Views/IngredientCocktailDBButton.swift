//
//  IngredientCocktailDBButton.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

public class IngredientCocktailDBButton: SimpleButton {
    var ingredient: IngredientBase? {
        didSet {
            if ingredient!.cocktaildb != "" {
                setTitle("\(ingredient!.name) on CocktailDB", forState: UIControlState.Normal)
            } else {
                removeFromSuperview()
            }
        }
    }
}