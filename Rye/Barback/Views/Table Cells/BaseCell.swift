//
//  RecipeCell.swift
//  Barback
//
//  Created by Justin Duke on 11/17/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class BaseCell : StyledCell {

    var base: IngredientBase? {
        didSet {
            textLabel?.text = self.base!.name
        }
    }

    init(base: IngredientBase, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: reuseIdentifier)

        let diagramView = IngredientDiagramView(frame: CGRect(x: 15.0, y: 15.0, width: 30.0, height: 30.0), ingredient: base)
        addSubview(diagramView)
        self.base = base
        textLabel?.text = self.base!.name
    }
    
    init(bases: [IngredientBase], reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: reuseIdentifier)
        
        let diagramView = IngredientDiagramView(frame: CGRect(x: 15.0, y: 15.0, width: 30.0, height: 30.0), ingredients: bases)
        addSubview(diagramView)
        self.base = bases.last!
        textLabel?.text = self.base!.name
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame.origin.x = 60
        detailTextLabel?.frame.origin.x = 60
    }

}