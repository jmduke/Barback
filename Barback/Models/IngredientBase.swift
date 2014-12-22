//
//  IngredientBase.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData
import Parse

class IngredientBase: StoredObject {

    @NSManaged var information: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var cocktaildb: String?
    @NSManaged var abv: NSNumber
    @NSManaged var brands: NSSet
    @NSManaged var uses: NSSet
    
    class func fromAttributes(valuesForKeys: [NSObject : AnyObject], checkForObject: Bool = true) -> IngredientBase {
        return managedContext().objectForDictionary(IngredientBase.self, dictionary: valuesForKeys, checkForObject: checkForObject)
    }

    class func syncWithParse() -> [IngredientBase] {
        let bases = PFQuery.allObjectsSinceSync("IngredientBase")
        return bases.map({
            (object: PFObject) -> IngredientBase in
            return IngredientBase.fromAttributes(object.toDictionary(self.attributes()))
        }) as [IngredientBase]
    }
    
    class func syncWithJSON() -> [IngredientBase] {
        let filepath = NSBundle.mainBundle().pathForResource("bases", ofType: "json")
        let jsonData = NSString(contentsOfFile: filepath!, encoding:NSUTF8StringEncoding, error: nil)!
        let baseData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawBases = NSJSONSerialization.JSONObjectWithData(baseData!, options: nil, error: nil) as [NSDictionary]
        
        var allBases: [IngredientBase] = rawBases.map({
            (rawBase: NSDictionary) -> IngredientBase in
            var base = self.fromAttributes(rawBase, checkForObject: false)
            let brands = (rawBase["brands"] as [NSDictionary]).map({
                (rawBrand: NSDictionary) -> Brand in
                let brand = Brand.fromAttributes(rawBrand, checkForObject: false)
                return brand
            })
            base.brands = NSSet(array: brands)
            
            return base
        })
        allBases = allBases.sorted({ $0.name < $1.name })
        return allBases
    }
    
    class func all() -> [IngredientBase] {
        return managedContext().objects(IngredientBase.self)!.filter({$0.isDead != true})
    }
    
    class func nameContainsString(string: String) -> [IngredientBase] {
        let predicate = NSPredicate(format: "name CONTAINS[cd] \"\(string)\"")
        return managedContext().objects(IngredientBase.self, predicate: predicate)!
    }
    
    class func forName(name: String) -> IngredientBase? {
        return managedContext().objectForName(IngredientBase.self, name: name)
    }
}
