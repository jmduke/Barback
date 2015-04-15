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

class IngredientBase: PFObject, PFSubclassing {

    @NSManaged var information: String
    @NSManaged var name: String
    @NSManaged var slug: String
    @NSManaged var type: String
    @NSManaged var cocktaildb: String?
    @NSManaged var abv: NSNumber
    @NSManaged var uses: NSSet
    @NSManaged var color: String?
    
    var uiColor: UIColor {
        get {
            if color == nil {
                return UIColor.redColor()
            }
            return UIColor.fromHex(color!)
        }
    }
    
    var brands: [Brand] {
        get {
            return Brand.query().fromLocalDatastore().whereKey("base", equalTo: self).findObjects() as! [Brand]
        }
    }
    
    class func parseClassName() -> String! {
        return "IngredientBase"
    }
    
    class func all() -> [IngredientBase] {
        return all(true)
    }
    
    class func all(useLocal: Bool) -> [IngredientBase] {
        var allQuery = query()
        allQuery.limit = 1000
        if (useLocal) {
            allQuery.fromLocalDatastore()
        }
        return allQuery.findObjects() as! [IngredientBase]
    }
    
    class func nameContainsString(string: String) -> [IngredientBase] {
        var nameQuery = query()
        nameQuery.whereKey("name", containsString: string)
        return nameQuery.findObjects()! as! [IngredientBase]
    }
    
    class func forName(name: String) -> IngredientBase {
        var nameQuery = query()
        nameQuery.whereKey("name", equalTo: name)
        return nameQuery.findObjects()![0] as! IngredientBase
    }
}
