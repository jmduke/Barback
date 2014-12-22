//
//  StoredObject.swift
//  Barback
//
//  Created by Justin Duke on 11/9/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import CoreData
import Parse

@objc(StoredObject)
public class StoredObject: NSManagedObject {

    @NSManaged var isDead: NSNumber?
    
}