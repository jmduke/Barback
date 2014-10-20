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
    
    class func fromAttributes(name: String, price: Int, context: NSManagedObjectContext) -> Brand {
        let newBrand: Brand = NSEntityDescription.insertNewObjectForEntityForName("Brand", inManagedObjectContext: context) as Brand
        newBrand.name = name
        newBrand.price = price
        return newBrand
    }
    
    class func fromDict(rawBrand: NSDictionary, context: NSManagedObjectContext) -> Brand {
        let name = rawBrand.objectForKey("name") as String
        let price = rawBrand.objectForKey("price") as Int
        return fromAttributes(name, price: price, context: context)
    }
    
    class func forName(name: String) -> Brand? {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let request = NSFetchRequest(entityName: "Brand")
        request.predicate = NSPredicate(format: "name == \"\(name)\"")
        
        let result = delegate.coreDataHelper.managedObjectContext!.executeFetchRequest(request, error: nil)
        return result?.first as? Brand
    }
    
}
