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
    @NSManaged var ingredient: IngredientBase

    var detailDescription: String {
        get {
            var priceRepresentation = ""
            for _ in 0..<Int(price) {
                priceRepresentation += "$"
            }
            return priceRepresentation
        }
    }
    
    class func forName(name: String) -> Brand? {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let request = NSFetchRequest(entityName: "Brand")
        request.predicate = NSPredicate(format: "name == \"\(name)\"")
        
        let result = delegate.coreDataHelper.managedObjectContext!.executeFetchRequest(request, error: nil)
        return result?.first as? Brand
    }
}
