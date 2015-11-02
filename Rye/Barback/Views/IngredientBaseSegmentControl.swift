//
//  IngredientBaseSegmentControl.swift
//  Barback
//
//  Created by Justin Duke on 5/21/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class IngredientBasesSegmentControl: SegmentControl {
    
    var baseGroups: [IngredientBaseGroup] = [] {
        didSet {
            (0...1).map({
                setTitle(baseGroups[$0].bases.first!.name, forSegmentAtIndex: $0)
            })
        }
    }
    
    var selectedBase: IngredientBaseGroup? {
        get {
            if selectedSegmentIndex == -1 {
                return nil
            }
            return baseGroups[selectedSegmentIndex]
        } set {
            selectedSegmentIndex = baseGroups.indexOf(newValue!)!
        }
    }
}