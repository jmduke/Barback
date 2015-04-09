//
//  RecipeCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class RecipeCell : StyledCell {
    
    var diagram: RecipeDiagramView?
    
    init(recipe: Recipe, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = recipe.name
        detailTextLabel?.text = recipe.detailDescription
        
        let diagram = RecipeDiagramView(recipe: recipe)
        diagram.strokeWidth = 1
        diagram.diagramScale = 0.4
        if recipe.favorite {
            diagram.outlineColor = Color.Tint.toUIColor()
            diagram.outlineWidth = 4
        }
        diagram.heightOffset = (60.0 - diagram.glassware.dimensions().0 * diagram.diagramScale) / 2.0
        diagram.widthOffset = (40.0 - diagram.glassware.dimensions().2 * diagram.diagramScale) / 2.0
        diagram.frame = CGRect(x: 10.0, y: 0.0, width: 40.0, height: 60.0)
        contentView.addSubview(diagram)
        self.diagram = diagram
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let leftPadding: CGFloat = 60
        let rightPadding: CGFloat = 16
        
        let bounds = contentView.bounds
        
        textLabel?.frame.origin.x = leftPadding
        detailTextLabel?.frame.origin.x = leftPadding
        detailTextLabel?.frame.size.width = min(detailTextLabel!.frame.size.width, bounds.width - (rightPadding + leftPadding))
    }

}