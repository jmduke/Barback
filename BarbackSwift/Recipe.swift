//
//  Recipe.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class Recipe {
    var name: String
    var directions: String
    var glassware: String
    var ingredients: Ingredient[]
    var favorited: Bool {
    get {
        var currentFavorites: NSMutableArray = NSMutableArray(array: NSUserDefaults.standardUserDefaults().arrayForKey("saved"))
        return currentFavorites.containsObject(self.name)
    }
    set(newBool) {
        var currentFavorites: NSMutableArray = NSMutableArray(array: NSUserDefaults.standardUserDefaults().arrayForKey("saved"))
        if currentFavorites.containsObject(self.name) && !newBool {
            currentFavorites.removeObject(self.name)
        } else if newBool {
            currentFavorites.addObject(self.name)
        }
        NSUserDefaults.standardUserDefaults().setObject(currentFavorites, forKey: "saved")
    }
    }
    var listedIngredients: String {
    get {
    let ingredients = self.ingredients.filter({ingredient in !ingredient.isSpecial}).map({
        (ingredient: Ingredient) -> String in
        return ingredient.base.name
        })
    return join(", ", ingredients)
    }
    }
    
    // Should only be used for 'fake' recipes.
    init(name: String) {
        self.name = name
        self.directions = ""
        self.glassware = ""
        self.ingredients = Ingredient[]()
    }
    
    init(name: String, directions: String, glassware: String, ingredients: Ingredient[]) {
        self.name = name
        self.directions = directions
        self.glassware = glassware
        self.ingredients = ingredients
    }
    
    init(rawRecipe: NSDictionary) {
        let rawString = rawRecipe.objectForKey("name") as AnyObject? as NSString?
        if let name = rawString as? NSString {
            self.name = name
        } else {
            self.name = "fuck"
        }
        
        self.directions = rawRecipe.objectForKey("preparation") as String
        
        self.glassware = rawRecipe.objectForKey("glass") as String
        
        let rawIngredients = rawRecipe.objectForKey("ingredients") as NSDictionary[]
        
        self.ingredients =  rawIngredients.map({
            (rawIngredient: NSDictionary) -> Ingredient in
            return Ingredient(rawIngredient: rawIngredient)
            })
    }
    
    class func allRecipes() -> Recipe[] {
        let filepath = NSBundle.mainBundle().pathForResource("recipes", ofType: "json")
        let jsonData = NSString.stringWithContentsOfFile(filepath, encoding:NSUTF8StringEncoding, error: nil)
        let recipeData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawRecipes = NSJSONSerialization.JSONObjectWithData(recipeData, options: nil, error: nil) as NSDictionary[]
        
        var allRecipes = rawRecipes.map({
            (rawRecipe: NSDictionary) -> Recipe in
            return Recipe(rawRecipe: rawRecipe)
            })
        allRecipes = sort(allRecipes) { $0.name < $1.name }
        return allRecipes
    }
    
    class func random() -> Recipe {
        let allRec = AllRecipes.sharedInstance
        return allRec[Int(arc4random_uniform(UInt32(allRec.count)))]
    }
    
    func matchesTerms(searchTerms: NSString[]) -> Bool {
        for term: NSString in searchTerms {
            // If the term matches the name of the recipe..
            if self.name.lowercaseString.hasPrefix(term) {
                continue
            }
            
            // Or at least one ingredient in it.
            let matchedIngredients = ingredients.filter({
                (ingredient: Ingredient) -> Bool in
                return ingredient.matchesTerm(term)
            })
            if matchedIngredients.count > 0 {
                continue
            }
            
            // Otherwise, no luck.
            return false
        }
        return true
    }
}

class AllRecipes {
    class var sharedInstance : Recipe[] {
        struct Static {
            static let instance : Recipe[] = Recipe.allRecipes()
        }
        return Static.instance
    }
}