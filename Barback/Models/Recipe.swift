//
//  Recipe.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import Mustache
import CoreData
import Parse

public class Recipe: StoredObject {

    @NSManaged var detail: String
    @NSManaged var directions: String
    @NSManaged var glassware: String
    @NSManaged var garnish: String?
    @NSManaged var name: String
    @NSManaged var slug: String?
    @NSManaged var information: String?
    
    @NSManaged var ingredientSet: NSSet
    var ingredients: [Ingredient] {
        get {
            let ingredientObjects = ingredientSet.allObjects as! [Ingredient]
            return ingredientObjects.filter({ $0.isDead != true })
        }
    }
    
    var parsedGarnishes: [Garnish] {
        let rawGarnishes: [String] = garnish?.componentsSeparatedByString(",") ?? []
        let parsedGarnishes: [Garnish] = rawGarnishes.map({ Garnish(rawGarnish: $0) })
        return parsedGarnishes
    }
    
    @NSManaged var isNew: Bool
    
    @NSManaged var isFavorited: NSNumber
    // Core Data won't let us store a bool so we use this (and isFavorited as a backend.)
    var favorite: Bool {
        get {
            return isFavorited as! Bool
        } set {
            isFavorited = NSNumber(bool: newValue)
        }
    }
    
    var url: NSURL {
        return externalUrl!.URLByAppendingPathComponent("recipe/\(slug!)")
    }
    
    var detailDescription: String {
        get {
            let sortedIngredients = ingredients.sorted({($0 as Ingredient).amount.intValue > ($1 as Ingredient).amount.intValue})
            
            // This should, uh, never happen.
            if sortedIngredients.count == 0 {
                return ""
            }
            
            let ingredientCountInDescription = 3
            let relevantIngredients = sortedIngredients[0...max(0,min(sortedIngredients.count - 1, ingredientCountInDescription))].map({
                (ingredient: Ingredient) -> String in
                return ingredient.base.name
            })
            return join(", ", relevantIngredients)
        }
    }
    
    var abv: Float {
        get {
            let amounts = ingredients.map({ Int($0.amount.intValue ?? 0) }) as [Int]
            let denominator = amounts.reduce(0, combine: +) as Int
            let numerator = (ingredients.map({
                (ingredient: Ingredient) -> Int in
                (ingredient.base.abv as Int).description
                let abv = ingredient.base.abv as Int
                let proportion = Int(ingredient.amount.intValue ?? 0)
                return abv * proportion
            }) as [Int]).reduce(0, combine: +)
            return Float(numerator) / Float(denominator)
        }
    }
    
    var htmlString: String {
        get {
            let hasGarnish = (garnish != nil && !garnish!.isEmpty)
            let hasInformation = (information != nil)
            var convertedMarkdown: String = ""
            if hasInformation {
                var markdownConverter = Markdown()
                convertedMarkdown = markdownConverter.transform(information!)
            }
            
            // Render using Mustache.
            let template = Template(named: "Recipe")!
            let data = [
                "parsedABV": round(abv),
                "recipe": self,
                "hasGarnish": hasGarnish,
                "hasInformation": hasInformation,
                "renderedInformation": convertedMarkdown
            ]
            let rendering = template.render(Box(data))!
            return rendering
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

    class func fromAttributes(valuesForKeys: [NSObject : AnyObject], checkForObject: Bool = true) -> Recipe {
        return managedContext().objectForDictionary(Recipe.self, dictionary: valuesForKeys, checkForObject: checkForObject)
    }
    
    class func syncWithParse() -> [Recipe] {
        let recipes = PFQuery.allObjectsSinceSync("Recipe")
        return recipes.map({
            (object: PFObject) -> Recipe in
            object.setValue(true, forKey: "isNew")
            return Recipe.fromAttributes(object.toDictionary(self.attributes()))
        }) as [Recipe]
    }
    
    class func syncWithJSON() -> [Recipe] {
        let filepath = NSBundle.mainBundle().pathForResource("recipes", ofType: "json")
        let jsonData = NSString(contentsOfFile: filepath!, encoding:NSUTF8StringEncoding, error: nil)!
        let recipeData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawRecipes = NSJSONSerialization.JSONObjectWithData(recipeData!, options: nil, error: nil) as! [NSDictionary]
        
        var allRecipes: [Recipe] = rawRecipes.map({
            (rawRecipe: NSDictionary) -> Recipe in
            var recipe = self.fromAttributes(rawRecipe as [NSObject : AnyObject], checkForObject: false)
            let ingredients = (rawRecipe["ingredients"] as! [NSDictionary]).map({
                (rawIngredient: NSDictionary) -> Ingredient in
                var ingredient = Ingredient.fromAttributes(rawIngredient as [NSObject : AnyObject], checkForObject: false)
                return ingredient
            })
            recipe.ingredientSet = NSSet(array: ingredients)
            return recipe
        })
        allRecipes = allRecipes.sorted({ $0.name < $1.name })
        return allRecipes
    }
    
    class func all() -> [Recipe] {
        return managedContext().objects(Recipe.self)!.filter({ $0.isDead != true }).sorted({ $0.name < $1.name })
    }
    
    class func random() -> Recipe {
        return managedContext().randomObject(Recipe.self)!
    }
    
    class func forName(name: String) -> Recipe? {
        return managedContext().objectForName(Recipe.self, name: name)
    }
}
