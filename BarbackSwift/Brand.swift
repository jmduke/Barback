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
    
    class func fromDict(rawBrand: NSDictionary) -> Brand {
        let name = rawBrand.objectForKey("name") as String
        let price = rawBrand.objectForKey("price") as Int
        let url = rawBrand.objectForKey("image") as String
        let baseName = rawBrand.objectForKey("base") as String
        
        let base = IngredientBase.forName(baseName)
        return fromAttributes(name, price: price, base: base!, url: url)
    }
    
    class func fromJSONFile(filename: String) -> [Brand] {
        let filepath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
        let jsonData = NSString(contentsOfFile: filepath!, encoding:NSUTF8StringEncoding, error: nil)!
        let ingredientData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawBrands = NSJSONSerialization.JSONObjectWithData(ingredientData!, options: nil, error: nil) as [NSDictionary]
        
        return rawBrands.map({Brand.fromDict($0)})
    }
}
