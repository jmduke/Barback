//
//  IngredientTypeDescriptionLabel.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

class IngredientTypeSectionLabel: DescriptionLabel {

    var ingredientType: IngredientType? {
        didSet {
            text = ingredientType!.pluralize().capitalizedString
            styleLabel()
        }
    }
}