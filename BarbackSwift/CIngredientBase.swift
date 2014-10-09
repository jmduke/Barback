//
//  CIngredientBase.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

class CIngredientBase: NSManagedObject {

    @NSManaged var information: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var brands: NSSet
    @NSManaged var uses: NSSet
    
    var lowercaseName: String {
        return name.lowercaseString
    }

    class func forName(name: String) -> CIngredientBase? {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let request = NSFetchRequest(entityName: "IngredientBase")
        request.predicate = NSPredicate(format: "name == \"\(name)\"")
        
        let result = delegate.coreDataHelper.managedObjectContext!.executeFetchRequest(request, error: nil)
        return result?.first as? CIngredientBase
    }
}
