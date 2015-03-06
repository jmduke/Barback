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

enum GarnishBase: String, Printable {
    case Cherry = "cherry"
    case Cucumber = "cucumber"
    case Lemon = "lemon"
    case Lime = "lime"
    case Orange = "orange"
    case Pineapple = "pineapple"
    case Mint = "mint"
    case Basil = "basil"
    case Blackberry = "blackberry"
    case Celery = "celery"
    case Olive = "olive"
    
    var description : String {
        get {
            return self.rawValue
        }
    }
}

enum GarnishType: String, Printable {
    case Chunk = "chunk"
    case Peel = "peel"
    case Slice = "slice"
    case Twist = "twist"
    case Wedge = "wedge"
    case Wheel = "wheel"
    case Leaves = "leaves"
    case Spear = "spear"
    case Sprig = "sprig"
    
    var description : String {
        get {
            return self.rawValue
        }
    }
}

struct Garnish: Printable {
    var base: GarnishBase?
    var type: GarnishType?
    var amount: Double
    var raw: String
    
    init(rawGarnish: String) {
        self.raw = rawGarnish
        let components = rawGarnish.componentsSeparatedByString(" ").map({
            $0.lowercaseString
        })
        
        switch components.count {
        // Descriptive case: `2 orange slice`
        case 3:
            amount = (components[0] as NSString).doubleValue
            base = GarnishBase(rawValue: components[1])
            type = GarnishType(rawValue: components[2])
        // Non-count case: `Lemon twist`
        case 2:
            amount = 1
            base = GarnishBase(rawValue: components[0])
            type = GarnishType(rawValue: components[1])
        // Basic case: `Cherry`
        case 1:
            amount = 1
            base = GarnishBase(rawValue: components[0])
        default:
            amount = 0
        }
    }
    
    var description: String {
        return "\(amount) \(base) \(type) (\(raw))"
    }
}

public class Recipe: StoredObject {

    @NSManaged var detail: String
    @NSManaged var directions: String
    @NSManaged var glassware: String
    @NSManaged var garnish: String?
    @NSManaged var name: String
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
            return isFavorited as Bool
        } set {
            isFavorited = NSNumber(bool: newValue)
        }
    }
    
    var url: NSURL {
        return externalUrl!.URLByAppendingPathComponent("/recipe/\(name)")
    }
    
    var isReal: Bool {
        return glassware != "" && directions != ""
    }
    
    var detailDescription: String {
        get {
            let sortedIngredients = ingredients.sorted({($0 as Ingredient).amount.intValue > ($1 as Ingredient).amount.intValue})
            let ingredientCountInDescription = 3
            let relevantIngredients = sortedIngredients[0...min(sortedIngredients.count - 1, ingredientCountInDescription)].map({
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
                NSLog((ingredient.base.abv as Int).description)
                let abv = ingredient.base.abv as Int
                let proportion = Int(ingredient.amount.intValue ?? 0)
                return abv * proportion
            }) as [Int]).reduce(0, combine: +)
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

    class func fromAttributes(valuesForKeys: [NSObject : AnyObject], checkForObject: Bool = true) -> Recipe {
        return managedContext().objectForDictionary(Recipe.self, dictionary: valuesForKeys, checkForObject: checkForObject)
    }
    
    class func syncWithParse() -> [Recipe] {
        let recipes = PFQuery.allObjectsSinceSync("Recipe")
        return recipes.map({
            (object: PFObject) -> Recipe in
            object["isNew"] = true
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
        return managedContext().objects(Recipe.self)!.filter({ $0.isReal && $0.isDead != true }).sorted({ $0.name < $1.name })
    }
    
    class func random() -> Recipe {
        return managedContext().randomObject(Recipe.self)!
    }
    
    class func forName(name: String) -> Recipe? {
        return managedContext().objectForName(Recipe.self, name: name)
    }
}
