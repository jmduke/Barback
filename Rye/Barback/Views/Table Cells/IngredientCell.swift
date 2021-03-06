//
//  RecipeCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

public class IngredientCell : StyledCell {

    var ingredient: Ingredient?

    public init(ingredient: Ingredient, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: reuseIdentifier)

        textLabel?.text = ingredient.base?.name ?? ""
        detailTextLabel?.text = ingredient.detailDescription

        if let _ = ingredient.base?.color {
            let diagramView = IngredientDiagramView(frame: CGRect(x: 15.0, y: 15.0, width: 30.0, height: 30.0), ingredient: ingredient.base!)
            addSubview(diagramView)
        }
        self.ingredient = ingredient
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame.origin.x = 60
        detailTextLabel?.frame.origin.x = 60
    }

}