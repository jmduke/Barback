//
//  IngredientBaseSegmentControl.swift
//  Barback
//
//  Created by Justin Duke on 5/21/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class IngredientBaseSegmentControl: SegmentControl {
    
    var ingredientBase: IngredientBase? {
        didSet {
            addSubview(IngredientDiagramView(frame: CGRect(x: 25, y: 25, width: self.frame.width / 5 - 50, height: self.frame.width / 5 - 50), ingredient: ingredientBase!))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}