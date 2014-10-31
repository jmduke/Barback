//
//  Recipe.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

public class Recipe: NSManagedObject {

    @NSManaged var detail: String
    @NSManaged var directions: String
    @NSManaged var glassware: String
    @NSManaged var isFavorited: NSNumber
    @NSManaged var name: String
    @NSManaged var ingredients: NSSet
    
    var isReal: Bool {
        return glassware != "" && directions != ""
    }
    
    var detailDescription: String {
        get {
            let ingredients = (self.ingredients.allObjects as [Ingredient]).sorted({$0.amount?.intValue > $1.amount?.intValue}).filter({ingredient in !ingredient.isSpecial}).map({
                (ingredient: Ingredient) -> String in
                return ingredient.base.name
            })
            return join(", ", ingredients)
        }
    }
    
    func similarRecipes(recipeCount: Int) -> [Recipe] {
        let ingredientBases = ingredients.allObjects.map({($0 as Ingredient).base.name})
        let numberOfSimilarIngredientsRequired = Int(ceil(Double(ingredients.count) / 2.0))
        
        var similarRecipes = managedContext().objects(Recipe.self)!.filter({
            (recipe: Recipe) -> Bool in
            let comparisonBases = recipe.ingredients.allObjects.map({$0.base.name})
            let matchedIngredients = ingredientBases.filter({ contains(comparisonBases, $0) })
            return matchedIngredients.count >= numberOfSimilarIngredientsRequired && recipe.name != self.name
        })
        
        if similarRecipes.count <= recipeCount {
            return similarRecipes
        }
        
        var chosenRecipes: [Recipe] = [Recipe]()
        while chosenRecipes.count < recipeCount {
            let randomIndex = Int(arc4random_uniform(UInt32(similarRecipes.count)))
            chosenRecipes.append(similarRecipes[randomIndex])
            similarRecipes.removeAtIndex(randomIndex)
        }
        return chosenRecipes
    }

    class func fromAttributes(name: String, directions: String, glassware: String) -> Recipe {
        let newRecipe: Recipe = NSEntityDescription.insertNewObjectForEntityForName("Recipe", inManagedObjectContext: managedContext()) as Recipe
        newRecipe.name = name
        newRecipe.directions = directions
        newRecipe.glassware = glassware
        newRecipe.isFavorited = false
        return newRecipe
    }
    
    class func fromDict(rawRecipe: NSDictionary) -> Recipe {
        let name = rawRecipe.objectForKey("name") as String
        let directions = rawRecipe.objectForKey("preparation") as String
        let glassware = rawRecipe.objectForKey("glass") as String
        let recipe = fromAttributes(name, directions: directions, glassware: glassware)
        
        let rawIngredients = rawRecipe.objectForKey("ingredients") as [NSDictionary]
        let ingredients = rawIngredients.map({
            (rawIngredient: NSDictionary) -> Ingredient in
            let ingredient = Ingredient.fromDict(rawIngredient)
            ingredient.recipe = recipe
            return ingredient
        })
        
        recipe.ingredients = NSSet(array: ingredients)
        
        return recipe
    }
    
    class func fromJSONFile(filename: String) -> [Recipe] {
        let filepath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
        let jsonData = NSString.stringWithContentsOfFile(filepath!, encoding:NSUTF8StringEncoding, error: nil)
        let recipeData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawRecipes = NSJSONSerialization.JSONObjectWithData(recipeData!, options: nil, error: nil) as [NSDictionary]
        
        var allRecipes: [Recipe] = rawRecipes.map({
            (rawRecipe: NSDictionary) -> Recipe in
            return self.fromDict(rawRecipe)
        })
        allRecipes = allRecipes.sorted({ $0.name < $1.name })
        return allRecipes
    }
}
