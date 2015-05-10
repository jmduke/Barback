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

public class Ingredient: PFObject, PFSubclassing {

    @NSManaged public var amount: NSNumber
    @NSManaged public var label: String?
    
    // Technically foreign keys.
    @NSManaged public var base: IngredientBase
    @NSManaged public var recipe: Recipe

    var lowercaseLabel: String? {
        return label?.lowercaseString
    }
    
    override public class func initialize() {
        registerSubclass()
    }
    
    public class func parseClassName() -> String! {
        return "Ingredient"
    }

    var displayAmount: String {
        let measurementType = userWantsImperialUnits() ? Measurement.Imperial : Measurement.Metric
        return measurementType.stringFromMetric(amount)
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
    
    public class func all() -> [Ingredient] {
        return all(true)
    }
    
    public class func all(useLocal: Bool) -> [Ingredient] {
        var allQuery = query()
        allQuery.limit = 1000
        if (useLocal) {
            allQuery.fromLocalDatastore()
        }
        return allQuery.findObjects() as! [Ingredient]
    }

}
