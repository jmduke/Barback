//
//  Ingredient.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class JSONIngredient {
    var base: String
    var amount: Float?
    var label: String?
    var lowercaseLabel: String?
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
    
    init(base: String, amount: Float?, label: String?, isSpecial: Bool) {
        self.base = base
        self.amount = amount
        self.label = label
        self.lowercaseLabel = label?.lowercaseString
        self.isSpecial = isSpecial
    }
    
    convenience init(rawIngredient: NSDictionary) {
        var baseName = rawIngredient.objectForKey("ingredient") as? String
        var isSpecial = false
        if !(baseName != nil) {
            baseName = rawIngredient.objectForKey("special") as? String
            isSpecial = true
        }
        let label = rawIngredient.objectForKey("label") as? String
        let amount = rawIngredient.objectForKey("cl") as? Float
        self.init(base: baseName!, amount: amount, label: label, isSpecial: isSpecial)
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