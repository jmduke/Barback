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
    
    var detailDescription: String {
        get {
            var price = ""
            for _ in 0..<self.price {
                price += "$"
            }
            return price
        }
    }
    
    init(name: String, price: Int) {
        self.name = name
        self.price = price
    }
    
    convenience init() {
        self.init(name: "", price: 0)
    }
    
    convenience init(rawBrand: NSDictionary) {
        let name = rawBrand.objectForKey("name") as String
        let price = rawBrand.objectForKey("price") as Int
        self.init(name: name, price: price)
    }
}