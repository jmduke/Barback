//
//  Ingredient.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData
import Parse

class Ingredient: NSManagedObject {

    @NSManaged var amount: NSNumber?
    @NSManaged var label: String?
    @NSManaged var isSpecial: NSNumber
    
    @NSManaged var base: IngredientBase
    @NSManaged var recipe: Recipe

    var lowercaseLabel: String? {
        return label?.lowercaseString
    }
    
    var displayAmount: String {
        let useImperialUnits = NSUserDefaults.standardUserDefaults().boolForKey("useImperialUnits")
        if let metricAmount = amount {
            if !useImperialUnits {
                return metricAmount.description + " cl"
            } else {
                var rawAmount = Int(floorf(metricAmount.floatValue / 3.0))
                var ounceString = ""
                if rawAmount > 0 {
                    ounceString = rawAmount.description
                }
                let imperialRemainder = metricAmount.floatValue % 3
                var remainderString: String = ""
                switch imperialRemainder {
                case 0.5:
                    remainderString = " ⅙"
                case 0.75:
                    remainderString = " ¼"
                case 1:
                    remainderString = " ⅓"
                case 1.5:
                    remainderString = " ½"
                case 2:
                    remainderString = " ⅔"
                default:
                    remainderString = ""
                }
                return "\(ounceString)\(remainderString) oz"
            }
        }
        return ""
    }

    var detailDescription: String {
        get {
            var extraInformation = self.displayAmount
            if let special = self.label {
                if !extraInformation.isEmpty {
                    extraInformation += " · "
                }
                extraInformation += special
            }
            return extraInformation
        }
    }
    
  
    class func syncWithParse() -> [Ingredient] {
        let ingredients = PFQuery.allObjectsSinceSync("Ingredient")
        return ingredients.map({
            (object: PFObject) -> Ingredient in
            var base = object["base"] as? String
            let amount = object["cl"] as? Float
            let label = object["label"] as? String
            let recipe = object["recipe"]! as String
            var isSpecial = false
            if base == nil {
                isSpecial = true
                base = object["special"]! as String
            }
            return Ingredient.fromAttributes(base!, amount: amount, label: label, isSpecial: isSpecial, recipeName: recipe)
        }) as [Ingredient]
    }
    
    
    class func fromAttributes(baseName: String?, amount: Float?, label: String?, isSpecial: Bool?, recipeName: String) -> Ingredient {
        let newIngredient: Ingredient = NSEntityDescription.insertNewObjectForEntityForName("Ingredient", inManagedObjectContext: managedContext()) as Ingredient
        
        var ingredientBase: IngredientBase? = IngredientBase.forName(baseName!)
        let recipe = Recipe.forName(recipeName)!
        
        if ingredientBase == nil {
            ingredientBase = (NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: managedContext()) as IngredientBase)
            ingredientBase!.name = baseName!
            ingredientBase!.information = ""
            ingredientBase!.type = "other"
        }

        newIngredient.base = ingredientBase!
        newIngredient.recipe = recipe
        newIngredient.amount = amount
        newIngredient.label = label
        newIngredient.isSpecial = isSpecial!
        
        return newIngredient
    }
    

}
