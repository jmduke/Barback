//
//  IngredientBase.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

class IngredientBase: NSManagedObject {

    @NSManaged var information: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var brands: NSSet
    @NSManaged var uses: NSSet
    
    var lowercaseName: String {
        return name.lowercaseString
    }

    class func forName(name: String) -> IngredientBase? {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let request = NSFetchRequest(entityName: "IngredientBase")
        request.predicate = NSPredicate(format: "name == \"\(name)\"")
        
        let result = delegate.coreDataHelper.managedObjectContext!.executeFetchRequest(request, error: nil)
        return result?.first as? IngredientBase
    }
    
    class func forJSONObject(ingredientBase: JSONIngredientBase, context: NSManagedObjectContext) -> IngredientBase {
        let newBase: IngredientBase = NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: context) as IngredientBase
        newBase.name = ingredientBase.name
        newBase.information = ingredientBase.description
        newBase.type = ingredientBase.type.toRaw()
        return newBase
    }
}
