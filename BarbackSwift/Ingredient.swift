//
//  Ingredient.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class Ingredient {
    var base: String
    var amount: Float?
    var label: String?
    var isSpecial = false
    
    init(base: String, amount: Float?, label: String?) {
        self.base = base
        self.amount = amount
        self.label = label
    }
    
    init(rawIngredient: NSDictionary) {
        var base = rawIngredient.objectForKey("ingredient") as? String
        if base {
            self.base = base!
        } else {
            self.base = rawIngredient.objectForKey("special") as String
            self.isSpecial = true
        }
        self.label = rawIngredient.objectForKey("label") as? String
        self.amount = rawIngredient.objectForKey("cl") as? Float
    }
    
    func description() -> String {
        return self.base
    }
    
    func matchesTerm(searchTerm: String) -> Bool {
        return self.base.lowercaseString.hasPrefix(searchTerm) || (self.label && self.label!.lowercaseString.hasPrefix(searchTerm))
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