//
//  CBrand.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

class CBrand: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var price: NSNumber
    @NSManaged var ingredient: CIngredientBase

    var detailDescription: String {
        get {
            var priceRepresentation = ""
            for _ in 0..<Int(price) {
                priceRepresentation += "$"
            }
            return priceRepresentation
        }
    }
    
    class func forName(name: String) -> CBrand? {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let request = NSFetchRequest(entityName: "Brand")
        request.predicate = NSPredicate(format: "name == \"\(name)\"")
        
        let result = delegate.coreDataHelper.managedObjectContext!.executeFetchRequest(request, error: nil)
        return result?.first as? CBrand
    }
}
