//
//  RecipeCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class BaseCell : StyledCell {
    
    var base: IngredientBase?
    
    init(base: IngredientBase, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = base.name
        
        if let color = base.color {
            let diagramView = IngredientDiagramView(frame: CGRect(x: 15.0, y: 15.0, width: 30.0, height: 30.0), ingredient: base)
            addSubview(diagramView)
        }
        self.base = base
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame.origin.x = 60
        detailTextLabel?.frame.origin.x = 60
        
        if let color = base!.color {
        }
    }
    
}