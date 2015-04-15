//
//  Garnish.swift
//  Barback
//
//  Created by Justin Duke on 4/14/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

enum GarnishBase: String, Printable {
    case Cherry = "cherry"
    case Cucumber = "cucumber"
    case Lemon = "lemon"
    case Lime = "lime"
    case Orange = "orange"
    case Pineapple = "pineapple"
    case Mint = "mint"
    case Basil = "basil"
    case Blackberry = "blackberry"
    case Celery = "celery"
    case Olive = "olive"
    
    var description : String {
        get {
            return self.rawValue
        }
    }
}

enum GarnishType: String, Printable {
    case Chunk = "chunk"
    case Peel = "peel"
    case Slice = "slice"
    case Twist = "twist"
    case Wedge = "wedge"
    case Wheel = "wheel"
    case Leaves = "leaves"
    case Spear = "spear"
    case Sprig = "sprig"
    
    var description : String {
        get {
            return self.rawValue
        }
    }
}

struct Garnish: Printable {
    var base: GarnishBase?
    var type: GarnishType?
    var amount: Double
    var raw: String
    
    init(rawGarnish: String) {
        self.raw = rawGarnish
        let components = rawGarnish.componentsSeparatedByString(" ").map({
            $0.lowercaseString
        })
        
        switch components.count {
            // Descriptive case: `2 orange slice`
        case 3:
            amount = (components[0] as NSString).doubleValue
            base = GarnishBase(rawValue: components[1])
            type = GarnishType(rawValue: components[2])
            // Non-count case: `Lemon twist`
        case 2:
            amount = 1
            base = GarnishBase(rawValue: components[0])
            type = GarnishType(rawValue: components[1])
            // Basic case: `Cherry`
        case 1:
            amount = 1
            base = GarnishBase(rawValue: components[0])
        default:
            amount = 0
        }
    }
    
    var description: String {
        return "\(amount) \(base) \(type) (\(raw))"
    }
}