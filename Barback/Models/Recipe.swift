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

public class Recipe: PFObject, PFSubclassing {

    @NSManaged public var directions: String
    @NSManaged public var glassware: String
    @NSManaged public var garnish: String?
    @NSManaged public var name: String
    @NSManaged var slug: String?
    @NSManaged public var information: String?
    
    public class func parseClassName() -> String! {
        return "Recipe"
    }
    
    override public class func initialize() {
        registerSubclass()
    }
    
    lazy public var ingredients: [Ingredient] = {
        print(self)
        return ingredientsForRecipes[self]!
    }()
    
    var parsedGarnishes: [Garnish] {
        let rawGarnishes: [String] = garnish?.componentsSeparatedByString(",") ?? []
        let parsedGarnishes: [Garnish] = rawGarnishes.map({ Garnish(rawGarnish: $0) })
        return parsedGarnishes
    }
    
    @NSManaged var isNew: Bool
    
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
    
    lazy public var abv: Float = {
        let amounts = self.ingredients.map({ Int($0.amount.intValue ?? 0) }) as [Int]
        let denominator = amounts.reduce(0, combine: +) as Int
        let numerator = (self.ingredients.map({
            (ingredient: Ingredient) -> Int in
            (ingredient.base.abv ?? 0 as Int).description
            let abv = ingredient.base.abv as Int
            let proportion = Int(ingredient.amount.intValue ?? 0)
            return abv * proportion
        }) as [Int]).reduce(0, combine: +)
        return Float(numerator) / Float(denominator)
    }()
    
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
    
    class public func all() -> [Recipe] {
        return all(true)
    }
    
    class public func all(useLocal: Bool) -> [Recipe] {
        var allQuery = query()
        allQuery.limit = 1000
        if (useLocal) {
            allQuery.fromLocalDatastore()
        }
        return allQuery.findObjects() as! [Recipe]
    }
    
    class func random() -> Recipe {
        let recipes =  all()
        let randomIndex = Int(arc4random_uniform(UInt32(recipes.count)))
        return recipes[randomIndex]
    }
    
    class func forName(name: String) -> Recipe {
        var nameQuery = query()
        nameQuery.whereKey("name", equalTo: name)
        return nameQuery.findObjects()![0] as! Recipe
    }
    
    class func favorites() -> [Recipe] {
        if let user = PFUser.currentUser() {
            var favoriteQuery = Favorite.query().fromLocalDatastore()
            favoriteQuery.whereKey("user", equalTo: user)
            let favorites = favoriteQuery.findObjects() as! [Favorite]
            return favorites.map({ $0.recipe })
        }
        return []
    }
}
