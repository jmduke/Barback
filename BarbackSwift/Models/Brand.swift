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
    @NSManaged var imageUrl: String
    @NSManaged var ingredient: IngredientBase

    var detailDescription: String {
        get {
            return "$\(price)"
        }
    }

    class func forName(name: String) -> Brand? {
        return managedContext().objectForName(Brand.self, name: name)
    }
    
    class func fromAttributes(name: String, price: Int, base: IngredientBase, url: String, isDead: Bool) -> Brand {
        let brand: Brand = Brand.forName(name) ?? NSEntityDescription.insertNewObjectForEntityForName("Brand", inManagedObjectContext: managedContext()) as Brand
        brand.name = name
        brand.price = price
        brand.imageUrl = url
        brand.ingredient = base
        brand.isDead = isDead
        return brand
    }
    
    class func syncWithParse() -> [Brand] {
        let brands = PFQuery.allObjectsSinceSync("Brand")
        return brands.map({
            (object: PFObject) -> Brand in
            let name = object["name"]! as String
            let price = object["price"]! as Int
            let base = IngredientBase.forName(object["base"]! as String)!
            let url = object["image"]! as String
            let isDead = object["isDeleted"] as? Bool ?? false
            return Brand.fromAttributes(name, price: price, base: base, url: url, isDead: isDead)
        }) as [Brand]
    }
}
