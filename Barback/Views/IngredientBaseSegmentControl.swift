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
    
    var bases: [IngredientBase] = [] {
        didSet {
            (0...2).map({
                setTitle(bases[$0].name, forSegmentAtIndex: $0)
            })
        }
    }
    
    var selectedBase: IngredientBase? {
        if selectedSegmentIndex == -1 {
            return nil
        }
        return bases[selectedSegmentIndex]
    }
}