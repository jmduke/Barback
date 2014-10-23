//
//  Brand.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

class Brand: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var price: NSNumber
    @NSManaged var ingredient: IngredientBase

    var detailDescription: String {
        get {
            var priceRepresentation = ""
            for _ in 0..<Int(price) {
                priceRepresentation += "$"
            }
            return priceRepresentation
        }
    }
    
    class func fromAttributes(name: String, price: Int, base: IngredientBase) -> Brand {
        let newBrand: Brand = NSEntityDescription.insertNewObjectForEntityForName("Brand", inManagedObjectContext: managedContext()) as Brand
        newBrand.name = name
        newBrand.price = price
        newBrand.ingredient = base
        return newBrand
    }
    
    class func fromDict(rawBrand: NSDictionary) -> Brand {
        let name = rawBrand.objectForKey("name") as String
        let price = rawBrand.objectForKey("price") as Int
        let baseName = rawBrand.objectForKey("base") as String
        
        let base = managedContext().objectForName(IngredientBase.self, name: baseName)!
        
        return fromAttributes(name, price: price, base: base)
    }
    
    override class func entityName() -> String {
        return "Brand"
    }
    
    class func fromJSONFile(filename: String) -> [Brand] {
        let filepath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
        let jsonData = NSString.stringWithContentsOfFile(filepath!, encoding:NSUTF8StringEncoding, error: nil)
        let ingredientData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawBrands = NSJSONSerialization.JSONObjectWithData(ingredientData!, options: nil, error: nil) as [NSDictionary]
        
        return rawBrands.map({Brand.fromDict($0)})
    }
}
