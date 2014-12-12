 //
//  Brand.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData
import Parse

class Brand: StoredObject {

    @NSManaged var name: String
    @NSManaged var price: NSNumber
    @NSManaged var url: String
    @NSManaged var ingredient: IngredientBase

    var detailDescription: String {
        get {
            return "$\(price)"
        }
    }

    class func forName(name: String) -> Brand? {
        return managedContext().objectForName(Brand.self, name: name)
    }
    
    class func fromAttributes(valuesForKeys: [NSObject : AnyObject]) -> Brand {
        let brand: Brand = Brand.forName(valuesForKeys["name"] as String) ?? NSEntityDescription.insertNewObjectForEntityForName("Brand", inManagedObjectContext: managedContext()) as Brand
        var objectValues: [String : AnyObject] = [:]
        for attribute: String in self.attributes() {
            let value: AnyObject? = valuesForKeys[attribute]
            if let value = value {
                objectValues[attribute] = value
            }
        }
        brand.setValuesForKeysWithDictionary(objectValues)
        return brand
    }
    
    class func syncWithParse() -> [Brand] {
        let brands = PFQuery.allObjectsSinceSync("Brand")
        return brands.map({
            (object: PFObject) -> Brand in
            let objectValues = [:]
            for attribute in self.attributes() {
                objectValues.setValue(object[attribute], forKey: attribute)
            }
            return Brand.fromAttributes(objectValues)
        }) as [Brand]
    }
}
