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

public class IngredientBase: PFObject, PFSubclassing {

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
    
    override public class func initialize() {
        registerSubclass()
    }
    
    var brands: [Brand] {
        get {
            return Brand.query().fromLocalDatastore().whereKey("base", equalTo: self).findObjects() as! [Brand]
        }
    }
    
    public class func parseClassName() -> String! {
        return "IngredientBase"
    }
    
    public class func all() -> [IngredientBase] {
        return all(true)
    }
    
    public class func all(useLocal: Bool) -> [IngredientBase] {
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
