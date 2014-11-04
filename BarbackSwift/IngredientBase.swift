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

class IngredientBase: NSManagedObject {

    @NSManaged var information: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var brands: NSSet
    @NSManaged var uses: NSSet
    
    override var description: String {
        return "ARGH"
    }
    
    class func fromAttributes(name: String, information: String, type: IngredientType) -> IngredientBase {
        let newBase: IngredientBase = NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: managedContext()) as IngredientBase
        newBase.name = name
        newBase.information = information
        newBase.type = type.rawValue ?? "other"
        return newBase
    }

    class func syncWithParse() -> [IngredientBase] {
        let bases = PFQuery.allObjectsSinceSync("IngredientBase")
        return bases.map({
            (object: PFObject) -> IngredientBase in
            let name = object["name"]! as String
            let information = object["description"]! as String
            let type = IngredientType(rawValue: object["type"]! as String)!
            return IngredientBase.fromAttributes(name, information: information, type: type)
        }) as [IngredientBase]
    }
    
    class func all() -> [IngredientBase] {
        return managedContext().objects(IngredientBase.self)!
    }
    
    class func nameContainsString(string: String) -> [IngredientBase] {
        let predicate = NSPredicate(format: "name CONTAINS[cd] \"\(string)\"")
        return managedContext().objects(IngredientBase.self, predicate: predicate)!
    }
    
    class func forName(name: String) -> IngredientBase? {
        return managedContext().objectForName(IngredientBase.self, name: name)
    }
}
