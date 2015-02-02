//
//  RecipeCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class RecipeCell : StyledCell {
    
    let newRecipeIconDiameter: CGFloat = 8
    
    init(recipe: Recipe, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = recipe.name
        detailTextLabel?.text = recipe.detailDescription
        
        var path: UIBezierPath?
        if recipe.favorite {
            let transform = CGAffineTransformMakeScale(0.8, 0.8)
            path = UIBezierPath.favoriteButton()
            path!.applyTransform(transform)
        } else if (recipe.isNew) {
            path = UIBezierPath(ovalInRect: CGRectMake(0, 0, CGFloat(newRecipeIconDiameter), CGFloat(newRecipeIconDiameter)))
        }
        imageView?.image = path?.toImageWithStrokeColor(Color.Lighter.toUIColor(), fillColor: Color.Lighter.toUIColor())
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let horizontalCellPadding: CGFloat = 16
        
        let bounds = contentView.bounds
        var frame = imageView?.frame
        frame?.origin.x = bounds.size.width - frame!.size.width - (frame!.size.width < newRecipeIconDiameter * 2 ? horizontalCellPadding + 3 : horizontalCellPadding)
        imageView?.frame = frame!
        
        textLabel?.frame.origin.x = horizontalCellPadding
        detailTextLabel?.frame.origin.x = horizontalCellPadding
    }

}