//
//  Ingredient.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

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
                var rawAmount = Int(floorf(metricAmount / 3))
                var ounceString = ""
                if rawAmount > 0 {
                    ounceString = rawAmount.description
                }
                let imperialRemainder = metricAmount % 3
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
    
    class func fromDict(rawIngredient: NSDictionary) -> Ingredient {
        var baseName = rawIngredient.objectForKey("ingredient") as? String
        var isSpecial = false
        if !(baseName != nil) {
            baseName = rawIngredient.objectForKey("special") as? String
            isSpecial = true
        }
        let label = rawIngredient.objectForKey("label") as? String
        let amount = rawIngredient.objectForKey("cl") as? Float
        return fromAttributes(baseName, amount: amount, label: label, isSpecial: isSpecial)
    }
    
    class func fromAttributes(baseName: String?, amount: Float?, label: String?, isSpecial: Bool?) -> Ingredient {
        let newIngredient: Ingredient = NSEntityDescription.insertNewObjectForEntityForName("Ingredient", inManagedObjectContext: managedContext()) as Ingredient
        var ingredientBase: IngredientBase? = managedContext().objectForName(IngredientBase.self, name: baseName!)
        if ingredientBase == nil {
            ingredientBase = (NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: managedContext()) as IngredientBase)
            ingredientBase!.name = baseName!
            ingredientBase!.information = ""
        }
        newIngredient.base = ingredientBase!
        
        newIngredient.amount = amount
        newIngredient.label = label
        newIngredient.isSpecial = isSpecial!
        return newIngredient
    }
    

}
