//
//  BrowseRecipesButton.swift
//  Barback
//
//  Created by Justin Duke on 8/13/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation

class BrowseRecipesForIngredientsButton: SimpleButton {

    var ingredients: [IngredientBase]? {
        didSet {

            let ingredientsString: String
            if ingredients!.count > 1 {
                // There's gotta be a nicer way to do this, right?
                let lastIngredient = ingredients!.removeLast()
                ingredientsString = ", ".join(ingredients!.map({ $0.name })) + " and \(lastIngredient.name)"
                ingredients!.append(lastIngredient)
            } else {
                ingredientsString = ", ".join(ingredients!.map({ $0.name }))
            }
            
            titleLabel!.numberOfLines = 0
            titleLabel!.textAlignment = NSTextAlignment.Center
            
            let recipes = Recipe.all().filter({
                (r: Recipe) in
                ingredients!.filter({ r.usesIngredient($0) }).count == ingredients!.count
            })
            
            let browseTitle = "Browse \(recipes.count) recipes with \(ingredientsString)"
            setTitle(browseTitle, forState: UIControlState.Normal)
            setTitleColor(Color.Tint.toUIColor(), forState: UIControlState.Normal)
        }
    }
}