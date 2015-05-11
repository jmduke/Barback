//
//  IngredientDescriptionTextView.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

public class IngredientDescriptionTextView: DescriptionTextView {
    
    var ingredient: IngredientBase? {
        didSet {
            text = ingredient!.information
            sizeToFit()
            layoutIfNeeded()
            if ingredient!.information == "" {
                removeFromSuperview()
            }
        }
    }
}