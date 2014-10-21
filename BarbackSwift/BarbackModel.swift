//
//  BarbackModel.swift
//  Barback
//
//  Created by Justin Duke on 10/19/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import CoreData
import Foundation

public class BarbackModel: NSManagedObject {
    
    class func entityName() -> String {
        return ""
    }
    
    class func forName(name: String) -> BarbackModel? {
        let request = NSFetchRequest(entityName: entityName())
        request.predicate = NSPredicate(format: "name == \"\(name)\"")
        
        let result = managedContext().executeFetchRequest(request, error: nil)
        return result?.first as? BarbackModel
    }
}