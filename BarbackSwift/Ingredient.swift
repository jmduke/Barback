//
//  Ingredient.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class Ingredient {
    var base: IngredientBase
    var amount: Float?
    var label: String?
    var isSpecial = false
    
    var detailDescription: String {
        get {
            var extraInformation = self.displayAmount()
            if let special = self.label {
                if !extraInformation.isEmpty {
                    extraInformation += " · "
                }
                extraInformation += special
            }
            return extraInformation
        }
    }
    
    init(base: String, amount: Float?, label: String?) {
        self.base = IngredientBase(name: base)
        self.amount = amount
        self.label = label
    }
    
    init(rawIngredient: NSDictionary) {
        var baseName = rawIngredient.objectForKey("ingredient") as? String
        if !baseName {
            baseName = rawIngredient.objectForKey("special") as? String
            self.isSpecial = true
        }
        self.base = IngredientBase.getIngredientBase(baseName!)
        self.label = rawIngredient.objectForKey("label") as? String
        self.amount = rawIngredient.objectForKey("cl") as? Float
    }
    
    func description() -> String {
        return self.base.name
    }
    
    func matchesTerm(searchTerm: String) -> Bool {
        return self.base.name.lowercaseString.bridgeToObjectiveC().containsString(searchTerm) || (self.label && self.label!.lowercaseString.bridgeToObjectiveC().containsString(searchTerm))
    }
    
    func displayAmount() -> String {
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
}