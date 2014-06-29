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
    var lowercaseName: String // Making this an actual variable for performance reasons.
    var brands: Brand[]
    var description: String
    
    convenience init() {
        self.init(name: "")
    }
    
    init(name: String, brands: Brand[], description: String) {
        self.name = name
        self.lowercaseName = name.lowercaseString
        self.brands = brands
        self.description = description
    }
    
    convenience init(name: String) {
        self.init(name: name, brands: Brand[](), description: "")
    }

    convenience init(rawIngredient: NSDictionary) {
        let name = (rawIngredient.objectForKey("name") as String)
        let description = rawIngredient.objectForKey("description") as String
        
        let rawBrands = rawIngredient.objectForKey("brands") as NSDictionary[]
        let brands = rawBrands.map({
            (rawBrand: NSDictionary) -> Brand in
            return Brand(rawBrand: rawBrand)
            })
        
        self.init(name: name, brands: brands, description: description)
    }
    
    class func getIngredientBase(fromName: String) -> IngredientBase {
        if let possibleMatch = AllIngredients.sharedInstance[fromName] {
            return possibleMatch
        }
        return IngredientBase(name: fromName)
    }
}

class AllIngredients {
    class var sharedInstance : Dictionary<String,IngredientBase> {
        struct Static {
        
            static let instance : Dictionary<String,IngredientBase> = Static.allIngredients()
            static func allIngredients() -> Dictionary<String,IngredientBase> {
                let filepath = NSBundle.mainBundle().pathForResource("ingredients", ofType: "json")
                let jsonData = NSString.stringWithContentsOfFile(filepath, encoding:NSUTF8StringEncoding, error: nil)
                let ingredientData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
                var rawIngredients = NSJSONSerialization.JSONObjectWithData(ingredientData, options: nil, error: nil) as NSDictionary[]
                
                var ingredientDict: Dictionary<String,IngredientBase> = [:]
                for rawIngredient in rawIngredients {
                    let ingredientBase = IngredientBase(rawIngredient: rawIngredient)
                    ingredientDict[ingredientBase.name] = ingredientBase
                }
                
                
                return ingredientDict
            }
        }
        return Static.instance
    }
}