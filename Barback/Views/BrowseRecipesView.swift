//
//  BrowseRecipesView.swift
//  Barback
//
//  Created by Justin Duke on 8/13/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation

class BrowseRecipesView: UIView {
    
    var delegate: AnyObject?
    
    var ingredients: [IngredientBase]? {
        didSet {
            let promptForIngredientDetail = (ingredients!.count == 1)
            let browseRecipesButtonY: Double = promptForIngredientDetail ? 80 : 0
            
            let browseRecipesButton = BrowseRecipesForIngredientsButton(frame: CGRectMake(self.frame.width / 4, CGFloat(browseRecipesButtonY), self.frame.width / 2, 120))
            browseRecipesButton.ingredients = ingredients
            browseRecipesButton.addTarget(delegate, action: "showRecipes", forControlEvents: UIControlEvents.TouchUpInside)
            addSubview(browseRecipesButton)
            
            if promptForIngredientDetail {
                let ingredientDetailButton = IngredientDetailButton(frame: CGRectMake(self.frame.width / 4, 0, self.frame.width / 2, 80))
                ingredientDetailButton.ingredient = ingredients!.first!
                ingredientDetailButton.addTarget(delegate, action: "showIngredient", forControlEvents: UIControlEvents.TouchUpInside)
                addSubview(ingredientDetailButton)
            } else {
                frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height - 80)
            }

        }
    }
}