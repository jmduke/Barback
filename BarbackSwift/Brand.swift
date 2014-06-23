//
//  Brand.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/22/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class Brand {
    var name: String
    var price: Int // ranges from 1 to 5
    
    init() {
        self.name = ""
        self.price = 0
    }
    
    init(rawBrand: NSDictionary) {
        self.name = rawBrand.objectForKey("name") as String
        self.price = rawBrand.objectForKey("price") as Int
    }
}