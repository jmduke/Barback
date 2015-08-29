//
//  RecipeSortingMethod.swift
//  Barback
//
//  Created by Justin Duke on 8/9/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation

enum RecipeSortingMethod: Int {
    case ABVDescending = 0
    case ABVAscending
    case ComplexityDescending
    case ComplexityAscending
    case NameDescending
    case NameAscending
    
    static func maximum() -> Int {
        // from http://stackoverflow.com/questions/26261011/swift-chose-a-random-enumeration-value
        var maxValue: Int = 0
        while let _ = self.init(rawValue: ++maxValue as Int) {}
        return maxValue
    }
    
    func title() -> String {
        return ["ABV", "Complexity", "Name"][rawValue / 2] + ["↓", "↑"][rawValue % 2]
    }
    
    func possibleMethods() -> [RecipeSortingMethod] {
        var rawValues: [Int]
        if (rawValue % 2 == 1) {
            rawValues = [0,2,4]
        } else if (rawValue == 0) {
            rawValues = [1,2,4]
        } else if (rawValue == 2) {
            rawValues = [0,3,4]
        } else {
            rawValues = [0,2,5]
        }
        return rawValues.map({RecipeSortingMethod(rawValue: $0)!})
    }
    
    func sortFunction() -> ((Recipe, Recipe) -> Bool) {
        func sortByABV(isDescending: Bool) -> ((Recipe, two: Recipe) -> Bool) {
            func ascending(one: Recipe, two: Recipe) -> Bool { return one.abv < two.abv }
            func descending(one: Recipe, two: Recipe) -> Bool { return one.abv > two.abv }
            return (isDescending ? descending : ascending)
        }
        func sortByComplexity(isDescending: Bool) -> ((Recipe, two: Recipe) -> Bool) {
            func ascending(one: Recipe, two: Recipe) -> Bool { return one.ingredients.count < two.ingredients.count }
            func descending(one: Recipe, two: Recipe) -> Bool { return one.ingredients.count > two.ingredients.count }
            return (isDescending ? descending : ascending)
        }
        func sortByName(isDescending: Bool) -> ((Recipe, two: Recipe) -> Bool) {
            func ascending(one: Recipe, two: Recipe) -> Bool { return one.name.lowercaseString > two.name.lowercaseString }
            func descending(one: Recipe, two: Recipe) -> Bool { return one.name.lowercaseString < two.name.lowercaseString }
            return (isDescending ? descending : ascending)
        }
        
        switch self {
        case .ABVDescending:
            return sortByABV(true)
        case .ABVAscending:
            return sortByABV(false)
        case .ComplexityDescending:
            return sortByComplexity(true)
        case .ComplexityAscending:
            return sortByComplexity(false)
        case .NameDescending:
            return sortByName(true)
        case .NameAscending:
            return sortByName(false)
        }
    }
}
