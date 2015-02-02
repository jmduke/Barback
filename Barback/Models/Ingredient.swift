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

class Ingredient: StoredObject {

    @NSManaged var amount: NSNumber
    @NSManaged var objectId: String
    @NSManaged var label: String?
    
    @NSManaged var base: IngredientBase
    @NSManaged var recipe: Recipe

    var lowercaseLabel: String? {
        return label?.lowercaseString
    }
    
    var displayAmount: String {
        if amount.intValue > 0 {
            let metricAmount = amount
            if !userWantsImperialUnits() {
                return "\(metricAmount.floatValue) cl"
            } else {
                let rawOunceCount = metricAmount.floatValue / 2
                let ounceString = rawOunceCount < 1 ? "" : "\(Int(rawOunceCount)) "
                let remainder = rawOunceCount % 1
                var remainderString: String = ""
                switch remainder {
                    case 0.25:
                        remainderString = "¼ "
                    case 0.5:
                        remainderString = "½ "
                    case 0.75:
                        remainderString = "¾ "
                    default:
                        remainderString = ""
                }
                return "\(ounceString)\(remainderString)oz"
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
            return Ingredient.fromAttributes(object.toDictionary(self.attributes()))
        }) as [Ingredient]
    }
    
    
    class func fromAttributes(valuesForKeys: [NSObject : AnyObject], checkForObject: Bool = true) -> Ingredient {
        var newIngredient = managedContext().objectForDictionary(Ingredient.self, dictionary: valuesForKeys, checkForObject: checkForObject)
        
        let baseName = valuesForKeys["base"] as String
        var ingredientBase: IngredientBase? = IngredientBase.forName(baseName)
        if ingredientBase == nil {
            ingredientBase = (NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: managedContext()) as IngredientBase)
            ingredientBase!.name = valuesForKeys["base"] as String
            ingredientBase!.information = ""
            ingredientBase!.type = "other"
            ingredientBase!.abv = 0
        }
        newIngredient.base = ingredientBase!
        
        if !isFirstTimeAppLaunched {
            let recipeName: AnyObject? = valuesForKeys["recipeName"]
            newIngredient.recipe = Recipe.forName(recipeName as String)!
        }
        
        return newIngredient
    }
    

}
