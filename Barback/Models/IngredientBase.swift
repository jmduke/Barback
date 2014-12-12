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
    @NSManaged var abv: NSNumber
    @NSManaged var brands: NSSet
    @NSManaged var uses: NSSet
    
    override var description: String {
        return "ARGH"
    }
    
    class func fromAttributes(valuesForKeys: [NSObject : AnyObject]) -> IngredientBase {
        let newBase: IngredientBase = IngredientBase.forName(valuesForKeys["name"] as String) ?? NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: managedContext()) as IngredientBase
        var objectValues: [String : AnyObject] = [:]
        for attribute: String in self.attributes() {
            let value: AnyObject? = valuesForKeys[attribute]
            if let value = value {
                objectValues[attribute] = value
            }
        }
        newBase.setValuesForKeysWithDictionary(objectValues)
        return newBase
    }

    class func syncWithParse() -> [IngredientBase] {
        let bases = PFQuery.allObjectsSinceSync("IngredientBase")
        return bases.map({
            (object: PFObject) -> IngredientBase in
            let objectValues = [:]
            for attribute in self.attributes() {
                objectValues.setValue(object[attribute], forKey: attribute)
            }
            return IngredientBase.fromAttributes(objectValues)
        }) as [IngredientBase]
    }
    
    class func syncWithJSON() -> [IngredientBase] {
        let filepath = NSBundle.mainBundle().pathForResource("bases", ofType: "json")
        let jsonData = NSString(contentsOfFile: filepath!, encoding:NSUTF8StringEncoding, error: nil)!
        let baseData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawBases = NSJSONSerialization.JSONObjectWithData(baseData!, options: nil, error: nil) as [NSDictionary]
        
        var allBases: [IngredientBase] = rawBases.map({
            (rawBase: NSDictionary) -> IngredientBase in
            var base = self.fromAttributes(rawBase)
            let brands = (rawBase["brands"] as [NSDictionary]).map({
                (rawBrand: NSDictionary) -> Brand in
                let brand = Brand.fromAttributes(rawBrand)
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
