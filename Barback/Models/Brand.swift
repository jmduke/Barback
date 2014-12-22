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
    
    class func fromAttributes(valuesForKeys: [NSObject : AnyObject], checkForObject: Bool = true) -> Brand {
        return managedContext().objectForDictionary(Brand.self, dictionary: valuesForKeys, checkForObject: checkForObject)
    }
    
    class func syncWithParse() -> [Brand] {
        let brands = PFQuery.allObjectsSinceSync("Brand")
        return brands.map({
            (object: PFObject) -> Brand in
            return Brand.fromAttributes(object.toDictionary(self.attributes()))
        }) as [Brand]
    }
}
