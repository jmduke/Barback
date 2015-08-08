//
//  IngredientCellSpec.swift
//  Barback
//
//  Created by Justin Duke on 8/8/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation
import Barback
import UIKit
import Nimble
import Quick

class IngredientCellSpec: QuickSpec {
    
    override func spec() {
        
        var ingredientCell: IngredientCell!
        
        describe("a ingredient cell with no label") {
            let recipe = Recipe.all().filter({ $0.name == "Manhattan" }).first!
            let ingredient = recipe.ingredients.first!
            ingredientCell = IngredientCell(ingredient: ingredient, reuseIdentifier: "testCell")
            
            it("should mention the ingredient") {
                expect(ingredientCell.textLabel?.text).to(contain(ingredient.base!.name))
            }
            
            it("should mention the amount") {
                expect(ingredientCell.detailTextLabel?.text).to(contain(ingredient.amount.description))
            }
            
            it("should not allot demarcation for a label") {
                expect(ingredientCell.detailTextLabel?.text).toNot(contain(" · "))
            }
            
        }

    }
}