//
//  Recipe.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData
import RealmSwift

public class Recipe: Object {

    public dynamic var directions: String = ""
    public dynamic var glassware: String = ""
    public dynamic var garnish: String = ""
    public dynamic var source: String = ""
    public dynamic var name: String = ""
    dynamic var slug: String = ""
    public dynamic var information: String = ""

    public class func parseClassName() -> String {
        return "Recipe"
    }

    public var ingredients = List<Ingredient>()

    var parsedSource: Source? {
        return Source(rawSource: self.source)
    }

    var parsedGarnishes: [Garnish] {
        let rawGarnishes: [String] = garnish.componentsSeparatedByString(",") ?? []
        let parsedGarnishes: [Garnish] = rawGarnishes.map({ Garnish(rawGarnish: $0) })
        return parsedGarnishes
    }

    var isNew: Bool = false

    var url: NSURL {
        return externalUrl!.URLByAppendingPathComponent("recipe/\(slug)")
    }

    var detailDescription: String {
        get {
            let sortedIngredients = ingredients.sort({$0.amount > $1.amount})
            
            // This should, uh, never happen.
            if sortedIngredients.count == 0 {
                return ""
            }
            
            let ingredientCountInDescription = 3
            let relevantIngredients = Array(sortedIngredients[0...max(0,min(sortedIngredients.count - 1, ingredientCountInDescription))].map({
                (ingredient: Ingredient) -> String in
                return (ingredient.base?.name ?? "")
            }))
            return ", ".join(relevantIngredients)
        }
    }

    lazy public var abv: Double = {
        let amounts = self.ingredients.map({ $0.amount ?? 0.0 }) as [Float]
        let denominator = amounts.reduce(0, combine: +) as Float
        let numerator = (self.ingredients.map({
            (ingredient: Ingredient) -> Double in
            (ingredient.base?.abv ?? 0.0 as Double).description
            let abv = ingredient.base?.abv ?? 0.0
            let proportion = Double(ingredient.amount ?? 0.0)
            return abv * proportion
        }) as [Double]).reduce(0.0, combine: +)
        return Double(numerator) / Double(denominator)
    }()

    var htmlString: String {
        get {
                        /*
            let hasGarnish = (garnish != nil && !garnish!.isEmpty)
            let hasInformation = (information != nil)
            var convertedMarkdown: String = ""
            if hasInformation {
                var markdownConverter = Markdown()
                convertedMarkdown = markdownConverter.transform(information!)
            }

            // Render using Mustache.
            let template = try! Template(named: "Recipe")
            let data = [
                "parsedABV": round(abv),
                "recipe": self,
                "hasGarnish": hasGarnish,
                "hasInformation": hasInformation,
                "renderedInformation": convertedMarkdown
            ]
            let rendering = try! template.render(Box(data))
            return rendering*/
            return ""
        }
    }

    func usesIngredient(ingredient: IngredientBase) -> Bool {
        let bases: [IngredientBase] = ingredients.filter({ $0.base != nil }).map({$0.base!})
        return bases.contains(ingredient)
    }

    func similarRecipes(recipeCount: Int) -> [Recipe] {
        let ingredientBases = ingredients.filter({ $0.base != nil }).map({$0.base!.name})
        let numberOfSimilarIngredientsRequired = Int(ceil(Double(ingredients.count) / 2.0))

        var similarRecipes = Recipe.all().filter({
            (recipe: Recipe) -> Bool in
            let comparisonBases = recipe.ingredients.filter({ $0.base != nil }).map({$0.base!.name})
            let matchedIngredients = ingredientBases.filter({ comparisonBases.contains($0) })
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
        do {
            return try Realm().objects(Recipe).sorted("name").map({ $0 })
        } catch {
            print("\(error)")
            return []
        }
    }

    class func random() -> Recipe {
        let recipes =  all()
        let randomIndex = Int(arc4random_uniform(UInt32(recipes.count)))
        return recipes[randomIndex]
    }

    class func forName(name: String) -> Recipe? {
        do {
            return try Realm().objects(Recipe).filter("name = '\(name)'").map({ $0 }).first
            
        } catch {
            print("\(error)")
            return nil
        }
    }

    class func favorites() -> [Recipe] {
        return []
    }
}
