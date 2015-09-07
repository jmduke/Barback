//
//  Garnish.swift
//  Barback
//
//  Created by Justin Duke on 4/14/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

enum GarnishBase: String, CustomStringConvertible {
    case Cherry
    case Cucumber
    case Lemon
    case Lime
    case Orange
    case Pineapple
    case Mint
    case Basil
    case Blackberry
    case Celery
    case Olive

    var description : String {
        get {
            return self.rawValue.lowercaseString
        }
    }
}

enum GarnishType: String, CustomStringConvertible {
    case Chunk
    case Peel
    case Slice
    case Twist
    case Wedge
    case Wheel
    case Leaves
    case Spear
    case Sprig

    var description : String {
        get {
            return self.rawValue.lowercaseString
        }
    }
}

struct Garnish: CustomStringConvertible {
    var base: GarnishBase?
    var type: GarnishType?
    var amount: Double
    var raw: String
    
    init(rawGarnish: String) {
        self.raw = rawGarnish
        let components = rawGarnish.componentsSeparatedByString(" ")
        
        switch components.count {
        // Descriptive case: `2 orange slice`
        case 3:
            amount = (components[0] as NSString).doubleValue
            base = GarnishBase(rawValue: components[1].capitalizedString)
            type = GarnishType(rawValue: components[2].capitalizedString)
        // Non-count case: `Lemon twist`
        // Or count basic: `2 cherry`
        case 2:
            if let garnishAmount = Double(components[0]) {
                amount = garnishAmount
                base = GarnishBase(rawValue: components[1].capitalizedString)
                
            } else {
                amount = 1
                base = GarnishBase(rawValue: components[0].capitalizedString)
                type = GarnishType(rawValue: components[1].capitalizedString)
            }
        // Basic case: `Cherry`
        case 1:
            amount = 1
            base = GarnishBase(rawValue: components[0].capitalizedString)
        default:
            amount = 0
        }
    }
    
    var description: String {
        return "\(amount) \(base) \(type) (\(raw))"
    }
}