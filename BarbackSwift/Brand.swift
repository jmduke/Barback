//
//  Brand.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

class Brand: BarbackModel {

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
    
    class func fromAttributes(name: String, price: Int) -> Brand {
        let newBrand: Brand = NSEntityDescription.insertNewObjectForEntityForName("Brand", inManagedObjectContext: managedContext()) as Brand
        newBrand.name = name
        newBrand.price = price
        return newBrand
    }
    
    class func fromDict(rawBrand: NSDictionary) -> Brand {
        let name = rawBrand.objectForKey("name") as String
        let price = rawBrand.objectForKey("price") as Int
        return fromAttributes(name, price: price)
    }
    
    override class func entityName() -> String {
        return "Brand"
    }
    
}
