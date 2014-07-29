//
//  IngredientType.swift
//  Barback
//
//  Created by Justin Duke on 7/28/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

enum IngredientType: String {
    case Spirit = "spirit", Liqueur = "liqueur", Garnish = "garnish", Mixer = "mixer", Other = "other"
    
    func pluralize() -> String {
        switch self {
        case .Garnish:
            return toRaw() + "es"
        default:
            return toRaw() + "s"
        }
    }
    
    // Ugh, this is so inelegant.
    static let allValues = [Spirit, Liqueur, Garnish, Mixer, Other]
}