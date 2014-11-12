//
//  Recipe.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData
import Parse

public class Recipe: StoredObject {

    @NSManaged var detail: String
    @NSManaged var directions: String
    @NSManaged var glassware: String
    @NSManaged var name: String
    
    @NSManaged var ingredientSet: NSSet
    var ingredients: [Ingredient] {
        get {
            let ingredientObjects = ingredientSet.allObjects as [Ingredient]
            return ingredientObjects.filter({ $0.isDead == false })
        }
    }
    
    @NSManaged var isFavorited: NSNumber
    // Core Data won't let us store a bool so we use this (and isFavorited as a backend.)
    var favorite: Bool {
        get {
            return isFavorited as Bool
        } set {
            isFavorited = NSNumber(bool: newValue)
        }
    }
    
    var isReal: Bool {
        return glassware != "" && directions != ""
    }
    
    var detailDescription: String {
        get {
            let sortedIngredients = ingredients.sorted({($0 as Ingredient).amount?.intValue > ($1 as Ingredient).amount?.intValue})
            let relevantIngredients = sortedIngredients.filter({ingredient in !((ingredient as Ingredient).isSpecial as Bool)}).map({
                (ingredient: Ingredient) -> String in
                return ingredient.base.name
            })
            return join(", ", relevantIngredients)
        }
    }
    
    var abv: Float {
        get {
            let amounts = ingredients.map({ Int($0.amount?.intValue ?? 0) }) as [Int]
            let denominator = amounts.reduce(0, combine: +) as Int
            let numerator = (ingredients.map({ ($0.base.abv as Int) * Int($0.amount?.intValue ?? 0) }) as [Int]).reduce(0, combine: +)
            return Float(numerator) / Float(denominator)
        }
    }
    
    func usesIngredient(ingredient: IngredientBase) -> Bool {
        let bases: [IngredientBase] = ingredients.map({$0.base})
        return contains(bases, ingredient)
    }
    
    func similarRecipes(recipeCount: Int) -> [Recipe] {
        let ingredientBases = ingredients.map({$0.base.name})
        let numberOfSimilarIngredientsRequired = Int(ceil(Double(ingredients.count) / 2.0))
        
        var similarRecipes = Recipe.all().filter({
            (recipe: Recipe) -> Bool in
            let comparisonBases = recipe.ingredients.map({$0.base.name})
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

    class func fromAttributes(name: String, directions: String, glassware: String, isDead: Bool) -> Recipe {
        let newRecipe: Recipe = Recipe.forName(name) ?? NSEntityDescription.insertNewObjectForEntityForName("Recipe", inManagedObjectContext: managedContext()) as Recipe
        newRecipe.name = name
        newRecipe.directions = directions
        newRecipe.glassware = glassware
        newRecipe.isFavorited = false
        newRecipe.isDead = isDead
        return newRecipe
    }
    
    class func syncWithParse() -> [Recipe] {
        let recipes = PFQuery.allObjectsSinceSync("Recipe")
        return recipes.map({
            (object: PFObject) -> Recipe in
            let name = object["name"]! as String
            let description = object["description"] as? String
            let garnish = object["garnish"] as? String
            let glass = object["glass"]! as String
            let directions = object["preparation"]! as String
            let isDead = object["isDeleted"] as? Bool ?? false
            return Recipe.fromAttributes(name, directions: directions, glassware: glass, isDead: isDead)
        }) as [Recipe]
    }
    
    class func all() -> [Recipe] {
        return managedContext().objects(Recipe.self)!.filter({ $0.isReal && $0.isDead == false })
    }
    
    class func random() -> Recipe {
        return managedContext().randomObject(Recipe.self)!
    }
    
    class func forName(name: String) -> Recipe? {
        return managedContext().objectForName(Recipe.self, name: name)
    }
}
