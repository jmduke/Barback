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

class Ingredient: PFObject, PFSubclassing {

    @NSManaged var amount: NSNumber
    @NSManaged var label: String?
    
    @NSManaged var base: IngredientBase
    
    @NSManaged var recipe: Recipe

    var lowercaseLabel: String? {
        return label?.lowercaseString
    }
    
    class func parseClassName() -> String! {
        return "Ingredient"
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
    
    class func all() -> [Ingredient] {
        return all(true)
    }
    
    class func all(useLocal: Bool) -> [Ingredient] {
        var allQuery = query()
        allQuery.limit = 1000
        if (useLocal) {
            allQuery.fromLocalDatastore()
        }
        return allQuery.findObjects() as! [Ingredient]
    }

}
