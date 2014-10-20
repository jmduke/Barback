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
    
    func matchesTerm(searchTerm: String) -> Bool {
        return
            (base.lowercaseName.rangeOfString(searchTerm) != nil) ||
                ((label != nil) && (lowercaseLabel!.rangeOfString(searchTerm) != nil))
    }
    
    class func fromDict(rawIngredient: NSDictionary, context: NSManagedObjectContext) -> Ingredient {
        var baseName = rawIngredient.objectForKey("ingredient") as? String
        var isSpecial = false
        if !(baseName != nil) {
            baseName = rawIngredient.objectForKey("special") as? String
            isSpecial = true
        }
        let label = rawIngredient.objectForKey("label") as? String
        let amount = rawIngredient.objectForKey("cl") as? Float
        return fromAttributes(baseName, amount: amount, label: label, isSpecial: isSpecial, context: context)
    }
    
    class func fromAttributes(baseName: String?, amount: Float?, label: String?, isSpecial: Bool?, context: NSManagedObjectContext) -> Ingredient {
        let newIngredient: Ingredient = NSEntityDescription.insertNewObjectForEntityForName("Ingredient", inManagedObjectContext: context) as Ingredient
        var ingredientBase: IngredientBase? = IngredientBase.forName(baseName!)
        if ingredientBase == nil {
            ingredientBase = (NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: context) as IngredientBase)
            ingredientBase!.name = baseName!
            ingredientBase!.information = ""
        }
        newIngredient.base = ingredientBase!
        
        newIngredient.amount = amount
        newIngredient.label = label
        newIngredient.isSpecial = isSpecial!
        return newIngredient
    }
    
    class func forName(name: String) -> Ingredient? {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let request = NSFetchRequest(entityName: "Ingredient")
        request.predicate = NSPredicate(format: "name == \"\(name)\"")
        
        let result = delegate.coreDataHelper.managedObjectContext!.executeFetchRequest(request, error: nil)
        return result?.first as? Ingredient
    }
}
