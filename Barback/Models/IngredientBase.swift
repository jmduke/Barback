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
    
    class func fromAttributes(name: String, information: String, type: IngredientType, abv: Int, isDead: Bool) -> IngredientBase {
        let newBase: IngredientBase = IngredientBase.forName(name) ?? NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: managedContext()) as IngredientBase
        newBase.name = name
        newBase.information = information
        newBase.type = type.rawValue ?? "other"
        newBase.abv = abv
        newBase.isDead = isDead
        return newBase
    }

    class func syncWithParse() -> [IngredientBase] {
        let bases = PFQuery.allObjectsSinceSync("IngredientBase")
        return bases.map({
            (object: PFObject) -> IngredientBase in
            let name = object["name"]! as String
            let information = object["information"]! as String
            let type = IngredientType(rawValue: object["type"]! as String)!
            let isDead = object["isDead"] as? Bool ?? false
            let abv = object["abv"] as? Int ?? 0
            return IngredientBase.fromAttributes(name, information: information, type: type, abv: abv, isDead: isDead)
        }) as [IngredientBase]
    }
    
    class func syncWithJSON() -> [IngredientBase] {
        let filepath = NSBundle.mainBundle().pathForResource("bases", ofType: "json")
        let jsonData = NSString(contentsOfFile: filepath!, encoding:NSUTF8StringEncoding, error: nil)!
        let baseData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawBases = NSJSONSerialization.JSONObjectWithData(baseData!, options: nil, error: nil) as [NSDictionary]
        
        var allBases: [IngredientBase] = rawBases.map({
            (rawBase: NSDictionary) -> IngredientBase in
            let base = self.fromAttributes(rawBase["name"] as String, information: rawBase["information"] as String, type: IngredientType(rawValue: rawBase["type"] as String)!, abv: rawBase["abv"] as? Int ?? 0, isDead: rawBase["isDead"] as? Bool ?? false)
            let brands = (rawBase["brands"] as [NSDictionary]).map({
                (rawBrand: NSDictionary) -> Brand in
                let brand = Brand.fromAttributes(rawBrand["name"] as String, price: rawBrand["price"] as Int, base: base, url: rawBrand["url"] as String, isDead: rawBrand["isDead"] as? Bool ?? false)
                return brand
            })
            return base
        })
        allBases = allBases.sorted({ $0.name < $1.name })
        return allBases
    }
    
    class func all() -> [IngredientBase] {
        return managedContext().objects(IngredientBase.self)!.filter({$0.isDead == false})
    }
    
    class func nameContainsString(string: String) -> [IngredientBase] {
        let predicate = NSPredicate(format: "name CONTAINS[cd] \"\(string)\"")
        return managedContext().objects(IngredientBase.self, predicate: predicate)!
    }
    
    class func forName(name: String) -> IngredientBase? {
        return managedContext().objectForName(IngredientBase.self, name: name)
    }
}
