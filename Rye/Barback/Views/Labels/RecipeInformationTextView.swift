//
//  RecipeInformationTextView.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

public class RecipeInformationTextView: DescriptionTextView {
    var recipe: Recipe? {
        didSet {
            var informationText = recipe!.information ?? ""
            
            if (recipe!.parsedSource != nil) {
                informationText += "\n\n The \(recipe!.name) \(recipe!.parsedSource!.prose())."
            }
            markdownText = informationText
            
            sizeToFit()
            layoutIfNeeded()
            
            // Most recipes don't have descriptions at this point.
            let labelShouldBeHidden = text == ""
            hidden = labelShouldBeHidden
        }
    }
}