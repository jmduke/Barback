//
//  Ingredient.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData
import RealmSwift

public class Ingredient: Object {

    public dynamic var amount: Float = 0.0
    public dynamic var label: String = ""

    // Technically foreign keys.
    public dynamic var base: IngredientBase?
    public dynamic var recipe: Recipe?
    
    public dynamic var baseName: String = ""

    var lowercaseLabel: String? {
        return label.lowercaseString
    }

    var displayAmount: String {
        let measurementType = userWantsImperialUnits() ? Measurement.Imperial : Measurement.Metric
        return measurementType.stringFromMetric(amount)
    }

    var detailDescription: String {
        get {
            var extraInformation = self.displayAmount
            if !extraInformation.isEmpty && !label.isEmpty {
                extraInformation += " · "
            }
            extraInformation += label
            return extraInformation
        }
    }

    public class func all() -> [Ingredient] {
        return (try? Realm().objects(Ingredient).map({ $0 })) ?? []
    }

}
