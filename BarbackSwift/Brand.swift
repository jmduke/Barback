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

class Brand: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var price: NSNumber
    @NSManaged var imageUrl: String
    @NSManaged var ingredient: IngredientBase

    var detailDescription: String {
        get {
            return String(count: price.integerValue, repeatedValue: Character("$"))
        }
    }
    
    class func fromAttributes(name: String, price: Int, base: IngredientBase, url: String) -> Brand {
        let newBrand: Brand = NSEntityDescription.insertNewObjectForEntityForName("Brand", inManagedObjectContext: managedContext()) as Brand
        newBrand.name = name
        newBrand.price = price
        newBrand.imageUrl = url
        newBrand.ingredient = base
        return newBrand
    }
    
    class func syncWithParse() -> [Brand] {
        let brands = PFQuery.allObjectsSinceSync("Brand")
        return brands.map({
            (object: PFObject) -> Brand in
            let name = object["name"]! as String
            let price = object["price"]! as Int
            let base = IngredientBase.forName(object["base"]! as String)!
            let url = object["image"]! as String
            return Brand.fromAttributes(name, price: price, base: base, url: url)
        }) as [Brand]
    }
}
