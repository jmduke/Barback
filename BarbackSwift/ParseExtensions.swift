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
}