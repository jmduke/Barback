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
        
        let diagram = RecipeDiagramView(recipe: recipe)
        diagram.strokeWidth = 1
        diagram.diagramScale = 0.4
        diagram.bgColor = UIColor.whiteColor()
        diagram.heightOffset = (60.0 - diagram.glassware.dimensions().0 * diagram.diagramScale) / 2.0
        diagram.widthOffset = (40.0 - diagram.glassware.dimensions().2 * diagram.diagramScale) / 2.0
        diagram.frame = CGRect(x: 10.0, y: 0.0, width: 40.0, height: 60.0)
        contentView.addSubview(diagram)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let leftPadding: CGFloat = 60
        let rightPadding: CGFloat = 16
        
        let bounds = contentView.bounds
        var frame = imageView?.frame
        frame?.origin.x = bounds.size.width - frame!.size.width - (frame!.size.width < newRecipeIconDiameter * 2 ? rightPadding + 3 : rightPadding)
        imageView?.frame = frame!
        
        textLabel?.frame.origin.x = leftPadding
        detailTextLabel?.frame.origin.x = leftPadding
        detailTextLabel?.frame.size.width = min(detailTextLabel!.frame.size.width, bounds.width - (rightPadding + leftPadding))
    }

}