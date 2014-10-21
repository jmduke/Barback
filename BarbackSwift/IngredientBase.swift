//
//  IngredientBase.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

class IngredientBase: BarbackModel {

    @NSManaged var information: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var brands: NSSet
    @NSManaged var uses: NSSet
    
    var lowercaseName: String {
        return name.lowercaseString
    }

    override class func entityName() -> String {
        return "IngredientBase"
    }
    
    class func fromAttributes(name: String, information: String, type: IngredientType) -> IngredientBase {
        let newBase: IngredientBase = NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: managedContext()) as IngredientBase
        newBase.name = name
        newBase.information = information
        newBase.type = type.toRaw()
        return newBase
    }
    
    class func fromDict(rawIngredient: NSDictionary) -> IngredientBase {
        let name = (rawIngredient.objectForKey("name") as String)
        let description = rawIngredient.objectForKey("description") as String
        let type = IngredientType.fromRaw(rawIngredient.objectForKey("type") as String)!
        //let rawBrands = rawIngredient.objectForKey("brands") as [NSDictionary]
        
        let base = fromAttributes(name, information: description, type: type)
        
        /*let newBrands = base.mutableSetValueForKey("brands")
        
        let brands = rawBrands.map({
            (rawBrand: NSDictionary) -> Brand in
            let brand = Brand.fromDict(rawBrand)
            newBrands.addObject(brand)
            return brand
        })*/
        return base
    }
    
    class func fromJSONFile(filename: String) -> [IngredientBase] {
        let filepath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
        let jsonData = NSString.stringWithContentsOfFile(filepath!, encoding:NSUTF8StringEncoding, error: nil)
        let ingredientData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawIngredients = NSJSONSerialization.JSONObjectWithData(ingredientData!, options: nil, error: nil) as [NSDictionary]
        
        return rawIngredients.map({IngredientBase.fromDict($0)})
    }
}
