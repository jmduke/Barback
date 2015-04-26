//
//  Favorite.swift
//  Barback
//
//  Created by Justin Duke on 4/16/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Parse
import Foundation

public class Favorite: PFObject, PFSubclassing {
    
    @NSManaged var user: PFUser
    @NSManaged var recipe: Recipe
    
    public class func parseClassName() -> String! {
        return "Favorite"
    }
    
    class func all() -> [Favorite] {
        return all(true)
    }
    
    class func all(useLocal: Bool) -> [Favorite] {
        var allQuery = query()
        allQuery.limit = 1000
        if (useLocal) {
            allQuery.fromLocalDatastore()
        }
        return allQuery.findObjects() as! [Favorite]
    }
    
    class func deleteSilently(user: PFUser, recipe: Recipe) {
        Favorite
            .query()
            .whereKey("user", equalTo: user)
            .whereKey("recipe", equalTo: recipe)
            .getFirstObjectInBackgroundWithBlock({
                (object, error) in
                    object?.deleteEventually()
            })
    }
    
}