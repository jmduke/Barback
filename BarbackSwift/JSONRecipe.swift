//
//  Recipe.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class JSONRecipe: Equatable {
    var name: String
    var lowercaseName: String // Actually making this a variable for performance reasons.
    var directions: String
    var glassware: String
    var ingredients: [JSONIngredient]
    
    var favorited: Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let savedFavorites = defaults.arrayForKey("saved")
            if (savedFavorites != nil) {
                var currentFavorites: NSMutableArray = NSMutableArray(array: savedFavorites!)
                return currentFavorites.containsObject(name)
            }
            return false
        }
        set(newBool) {
            var savedFavorites = NSUserDefaults.standardUserDefaults().arrayForKey("saved")
            if (savedFavorites == nil) {
                savedFavorites = []
            }
            var currentFavorites: NSMutableArray = NSMutableArray(array: savedFavorites!)
            if currentFavorites.containsObject(name) && !newBool {
                currentFavorites.removeObject(name)
            } else if newBool {
                currentFavorites.addObject(name)
            }
            NSUserDefaults.standardUserDefaults().setObject(currentFavorites, forKey: "saved")
        }
    }
    
    var detailDescription: String {
        get {
        let ingredients = self.ingredients.filter({ingredient in !ingredient.isSpecial}).map({
            (ingredient: JSONIngredient) -> String in
            return ingredient.base
            })
        return join(", ", ingredients)
        }
    }
    
    // Should only be used for 'fake' recipes.
    convenience init(name: String) {
        self.init(name: name, directions: "", glassware: "", ingredients: [JSONIngredient]())
    }
    
    init(name: String, directions: String, glassware: String, ingredients: [JSONIngredient]) {
        self.name = name
        self.lowercaseName = name.lowercaseString
        self.directions = directions
        self.glassware = glassware
        self.ingredients = ingredients
    }
    
    convenience init(rawRecipe: NSDictionary) {
        let name = rawRecipe.objectForKey("name") as String
        let directions = rawRecipe.objectForKey("preparation") as String
        let glassware = rawRecipe.objectForKey("glass") as String
        
        let rawIngredients = rawRecipe.objectForKey("ingredients") as [NSDictionary]
        let ingredients = rawIngredients.map({
            (rawIngredient: NSDictionary) -> JSONIngredient in
            return JSONIngredient(rawIngredient: rawIngredient)
            })
        
        self.init(name: name, directions: directions, glassware: glassware, ingredients: ingredients)
    }

    class func fromJSONFile() -> [JSONRecipe] {
        let filepath = NSBundle.mainBundle().pathForResource("recipes", ofType: "json")
        let jsonData = NSString.stringWithContentsOfFile(filepath!, encoding:NSUTF8StringEncoding, error: nil)
        let recipeData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawRecipes = NSJSONSerialization.JSONObjectWithData(recipeData!, options: nil, error: nil) as [NSDictionary]
        
        var allRecipes: [JSONRecipe] = rawRecipes.map({
            (rawRecipe: NSDictionary) -> JSONRecipe in
            return JSONRecipe(rawRecipe: rawRecipe)
        })
        allRecipes = allRecipes.sorted({ $0.name < $1.name })
        return allRecipes
    }
}


func == (lhs: JSONRecipe, rhs: JSONRecipe) -> Bool {
    return lhs.name == rhs.name
}