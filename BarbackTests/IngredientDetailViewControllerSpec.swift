//
//  RecipeDetailViewControllerSpec.swift
//  Barback
//
//  Created by Justin Duke on 5/9/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import Barback
import UIKit
import Nimble
import Quick

class IngredientDetailViewControllerSpec: QuickSpec {

    override func spec() {

        describe("an ingredient detail view controller") {
            
            var controller: IngredientDetailViewController!
            beforeEach {
                controller = R.storyboard.main.ingredientDetail!
            }
            
            context("when it has a standard base") {
                let ingredient = IngredientBase.all().filter({ $0.name == "Rye" })[0]
                
                beforeEach {
                    controller.ingredient = ingredient
                    let _ = controller.view
                }
                
                it("should have the ingredient name") {
                    expect(controller.headerLabel.text).to(equal(ingredient.name))
                }
                
                it("should have ingredient information") {
                    expect(controller.descriptionView.text[0...20]).to(equal(ingredient.information[0...20]))
                }
                
                it("should have the ingredient's abv") {
                    expect(controller.subheaderLabel.text).to(contain(Int(ingredient.abv).description))
                }
                
                it("should have recipes which use that ingredient") {
                    var cells = [UITableViewCell]()
                    for useIndex in 0..<ingredient.uses.count {
                        cells.append(controller.drinksTableView.tableView(controller.drinksTableView, cellForRowAtIndexPath: NSIndexPath(forRow: useIndex, inSection: 0)))
                    }
                    expect(cells.count).to(equal(ingredient.uses.count))
                    for use in ingredient.uses {
                        expect(cells.map({ $0.textLabel!.text! })).to(contain(use.recipe!.name))
                    }
                }
                
                
            }
        }
    }
}