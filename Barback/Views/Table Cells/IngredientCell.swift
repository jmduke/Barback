//
//  RecipeCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class IngredientCell : StyledCell {
    
    var ingredient: Ingredient?

    init(ingredient: Ingredient, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = ingredient.base.name
        detailTextLabel?.text = ingredient.label
        
        let diagram = UIBezierPath(ovalInRect: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        if let color = ingredient.base.color {
            let fillColor = UIColor.fromHex(color)
            let image = diagram.toImageWithStrokeColor(fillColor, fillColor: fillColor)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 15.0, y: 15.0, width: 30.0, height: 30.0)
            addSubview(imageView)
        }
        self.ingredient = ingredient
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame.origin.x = 60
        detailTextLabel?.frame.origin.x = 60
        
        if let color = ingredient!.base.color {
        }
    }
    
}