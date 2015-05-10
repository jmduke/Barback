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

public class Brand: PFObject, PFSubclassing {

    @NSManaged var name: String
    @NSManaged var price: NSNumber
    @NSManaged var url: String
    @NSManaged var ingredient: IngredientBase

    var detailDescription: String {
        get {
            return "$\(price)"
        }
    }
    
    override public class func initialize() {
        registerSubclass()
    }
    
    public class func all() -> [Brand] {
        return all(true)
    }
    
    public class func all(useLocal: Bool) -> [Brand] {
        var allQuery = query()
        allQuery.limit = 1000
        if (useLocal) {
            allQuery.fromLocalDatastore()
        }
        return allQuery.findObjects() as! [Brand]
    }
    
    public class func parseClassName() -> String! {
        return "Brand"
    }

    class func forName(name: String) -> Brand {
        var nameQuery = query()
        nameQuery.whereKey("name", equalTo: name)
        return nameQuery.findObjects()![0] as! Brand
    }
}
