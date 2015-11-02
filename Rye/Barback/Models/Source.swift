//
//  Source.swift
//  Barback
//
//  Created by Justin Duke on 5/18/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

// This drink was invented by X.
// This drink first appeared in X.
// This drink was found at X.

let affiliateTag = "&tag=barback-20"

let recognizedPeople = [
    "Ada Coleman",
    "Audrey Sanders",
    "C.A. Tuck",
    "Charles Baker",
    "Chris Hannah",
    "Duncan Nicol",
    "Dushan Zaric",
    "Giuseppe Cipriani",
    "Gaspare Campari",
    "Harry MacElhone",
    "Jeffrey Morganthaler",
    "Philibert Guichet",
    "Toby Maloney"
]

let recognizedBooks = [
    "Barflies and Cocktails": "http://www.amazon.com/Barflies-Cocktails-Harry-McElhone/dp/1603111697",
    "Old Waldorf Bar Days": "http://www.amazon.com/Waldorf-Astoria-Book-1935-Reprint-ebook/dp/B007VGGNWA",
    "The Savoy Cocktail Book": "http://www.amazon.com/Savoy-Cocktail-Book-Harry-Craddock/dp/1614274304",
    "Famous New Orleans Drinks and How to Mix ''Em": "http://www.amazon.com/Famous-New-Orleans-Drinks-How/dp/0882891324",
    "Recipes for Mixed Drinks": "http://www.amazon.com/Recipes-Mixed-Drinks-Hugo-Ensslin/dp/1603111905",
    "The Fine Art of Mixing Drinks": "http://www.amazon.com/The-Fine-Art-Mixing-Drinks/dp/1603111646",
    "New American Bartender's Guide": "http://www.amazon.com/New-American-Bartenders-Guide/dp/0451205243",
    "Just Cocktails": "http://www.amazon.com/Just-Cocktails-Bartenders-Illustrated-Engage/dp/1927970016",
    "Cocktails and How to Mix Them": "http://www.amazon.com/Cocktails-How-Them-Robert-Vermeire-ebook/dp/B00B9GR6C4",
    "The Ideal Bartender": "http://www.amazon.com/Ideal-Bartender-1917-Reprint/dp/1440457409",
    "Casino Royale": "http://www.amazon.com/Casino-Royale-James-Bond-007/dp/1612185436",
    "The Essential Cocktail" : "http://www.amazon.com/Essential-Cocktail-Mixing-Perfect-Drinks/dp/0307405737"
]

let recognizedSites = [
    "cocktail virgin/slut": "http://cocktailvirgin.blogspot.com",
    "Pisco Trail": "http://www.piscotrail.com",
    "Boozenerds": "http://boozenerds.com"
]

public enum SourceType {
    case Book
    case Person
    case Site
    case Etc

    static func fromName(sourceName: String) -> SourceType {
        if recognizedPeople.contains(sourceName) {
            return .Person
        }
        if recognizedBooks.keys.contains(sourceName) {
            return .Book
        }
        if recognizedSites.keys.contains(sourceName) || sourceName.rangeOfString("http") != nil {
            return .Site
        }
        return .Etc
    }
}

public struct Source {
    public var type: SourceType
    public var name: String

    public init?(rawSource: String) {
        if rawSource == "" {
            return nil
        }
        name = rawSource
        type = SourceType.fromName(rawSource)
    }

    public func prose() -> String {
        switch type {
            case .Book:
                return "first appeared in [\(name)](\(recognizedBooks[name]!+affiliateTag))"
            case .Person:
                return "was invented by *\(name)*"
            case .Site:
                if let url = recognizedSites[name] {
                    return "was found online at [\(name)](\(url))"
                } else {
                    return "was found [online](\(name))"
                }
            default:
                return "came from *\(name)*"
        }
    }
}