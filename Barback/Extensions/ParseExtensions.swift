//
//  ParseExtensions.swift
//  Barback
//
//  Created by Justin Duke on 11/3/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import Parse

extension PFQuery {
    
    class func allObjects(className: String) -> [PFObject] {
        var query = PFQuery(className: className)
        query.limit = 1000
        return query.findObjects() as [PFObject]
    }
    
    class func allObjectsSinceSync(className: String) -> [PFObject] {
        var query = PFQuery(className: className)
        query.limit = 1000
        
        let mostRecentSyncString = NSUserDefaults.standardUserDefaults().stringForKey("syncDate")
        
        if let mostRecentSyncString = mostRecentSyncString {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let mostRecentSyncDate = formatter.dateFromString(mostRecentSyncString)
            
            query.whereKey("updatedAt", greaterThan: mostRecentSyncDate!)
        }
        
        return query.findObjects() as [PFObject]
    }
}

extension PFObject {
    
    func toDictionary(attributes: [String]) -> [String: AnyObject] {
        var objectValues: [String: AnyObject] = [:]
        for attribute in attributes {
            let dictionedValue = self.valueForKey(attribute.stringByReplacingOccurrencesOfString("Name", withString: "", options: nil, range: nil))
            objectValues[attribute] = dictionedValue
        }
        return objectValues
    }
}