//
//  RecipeCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class RecipeCell : StyledCell {
    
    init(recipe: Recipe, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = recipe.name
        detailTextLabel?.text = recipe.detailDescription
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}