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

    class func forObjectId(objectId: String) -> Ingredient? {
        return managedContext().objectForObjectId(Ingredient.self, objectId: objectId)
    }
    
  
    class func syncWithParse() -> [Ingredient] {
        let ingredients = PFQuery.allObjectsSinceSync("Ingredient")
        return ingredients.map({
            (object: PFObject) -> Ingredient in
            return Ingredient.fromAttributes(object.toDictionary(self.attributes()))
        }) as [Ingredient]
    }
    
    
    class func fromAttributes(valuesForKeys: [NSObject : AnyObject]) -> Ingredient {
        let newIngredient: Ingredient = Ingredient.forObjectId(valuesForKeys["objectId"] as String) ?? NSEntityDescription.insertNewObjectForEntityForName("Ingredient", inManagedObjectContext: managedContext()) as Ingredient
        newIngredient.updateWithDictionary(valuesForKeys)
        
        var ingredientBase: IngredientBase? = IngredientBase.forName(valuesForKeys["base"] as String)
        if ingredientBase == nil {
            ingredientBase = (NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: managedContext()) as IngredientBase)
            ingredientBase!.name = valuesForKeys["base"] as String
            ingredientBase!.information = ""
            ingredientBase!.type = "other"
            ingredientBase!.abv = 0
        }
        newIngredient.base = ingredientBase!
        
        return newIngredient
    }
    

}
