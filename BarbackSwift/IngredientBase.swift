//
//  IngredientBase.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/22/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class IngredientBase {
    var name: String
    var brands: Brand[]
    var description: String
    
    convenience init() {
        self.init(name: "")
    }
    
    init(name: String) {
        self.name = name
        self.brands = Brand[]()
        self.description = ""
    }
    
    class func getIngredientBase(fromName: String) -> IngredientBase {
        let possibleMatch: IngredientBase[] = AllIngredients.sharedInstance.filter({$0.name == fromName})
        if possibleMatch.count > 0 {
            return possibleMatch[0]
        }
        return IngredientBase(name: fromName)
    }
    
    
    init(rawIngredient: NSDictionary) {
        self.name = (rawIngredient.objectForKey("name") as String)
        self.description = rawIngredient.objectForKey("description") as String
        
        let rawBrands = rawIngredient.objectForKey("brands") as NSDictionary[]
        
        self.brands =  rawBrands.map({
            (rawBrand: NSDictionary) -> Brand in
            return Brand(rawBrand: rawBrand)
            })
    }

    
    class func allIngredients() -> IngredientBase[] {
        let filepath = NSBundle.mainBundle().pathForResource("ingredients", ofType: "json")
        let jsonData = NSString.stringWithContentsOfFile(filepath, encoding:NSUTF8StringEncoding, error: nil)
        let ingredientData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawIngredients = NSJSONSerialization.JSONObjectWithData(ingredientData, options: nil, error: nil) as NSDictionary[]
        
        var allIngredients = rawIngredients.map({
            (rawIngredient: NSDictionary) -> IngredientBase in
            return IngredientBase(rawIngredient: rawIngredient)
            })
        allIngredients = sort(allIngredients) { $0.name < $1.name }

        return allIngredients
    }
}

class AllIngredients {
    class var sharedInstance : IngredientBase[] {
    struct Static {
        static let instance : IngredientBase[] = IngredientBase.allIngredients()
        }
        return Static.instance
    }
}