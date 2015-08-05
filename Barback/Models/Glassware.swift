//
//  Glassware.swift
//  Barback
//
//  Created by Justin Duke on 4/14/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

enum Glassware {
    case Champagne
    case Cocktail
    case Collins
    case Goblet
    case Hurricane
    case Highball
    case Margarita
    case Martini
    case Mug
    case OldFashioned
    case Rocks
    case Shot

    func dimensions() -> (Double, Double, Double) {
        let base: (Double, Double, Double) = {
            switch self {
            case .Champagne:
                return (100.0, 0.0, 30.0)
            case .Cocktail, .Martini:
                return (50.0, 0.0, 60.0)
            case .Collins, .Highball:
                return (100.0, 40.0, 40.0)
            case .Goblet:
                return (100.0, 30.0, 90.0)
            case .Hurricane:
                return (100.0, 50.0, 80.0)
            case .Mug, .OldFashioned, .Rocks:
                return (60.0, 80.0, 80.0)
            case .Shot:
                return (40.0, 30.0, 40.0)
            case .Margarita:
                return (50.0, 10.0, 90.0)
            }
            }()
        return base
    }

    func rect() -> CGRect {
        return CGRectMake(0.0, 0.0, CGFloat(dimensions().2), CGFloat(dimensions().0))
    }

    static func fromString(string: String) -> Glassware {
        switch string {
        case "champagne flute":
            return .Champagne
        case "cocktail":
            return .Cocktail
        case "collins":
            return .Collins
        case "goblet":
            return .Goblet
        case "hurricane":
            return .Hurricane
        case "highball":
            return .Highball
        case "mug":
            return .Mug
        case "old fashioned":
            return .OldFashioned
        case "rocks":
            return .Rocks
        case "shot":
            return .Shot
        case "margarita":
            return .Margarita
        case "martini":
            return .Martini
        default:
            return .Martini
        }
    }
}