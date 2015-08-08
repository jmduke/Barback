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

extension String {

    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

class RecipeDetailViewControllerSpec: QuickSpec {

    override func spec() {

        describe("a recipe detail view controller") {
            
            var controller: RecipeDetailViewController!
            beforeEach {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                controller =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "recipeDetail") as! RecipeDetailViewController
            }
            
            context("when it has a recipe without a source") {
                let recipe = Recipe.all().filter({ $0.name == "Alabama Slammer" })[0]
                
                beforeEach {
                    controller.setRecipeAs(recipe)
                    let _ = controller.view
                }
                
                it("should not have the placeholder source text") {
                    expect(controller.informationLabel.text).toNot(contain("came from"))
                }
            }
            
            context("when it has a standard recipe") {
                let recipe = Recipe.all().filter({ $0.name == "Manhattan" })[0]
                
                beforeEach {
                    controller.setRecipeAs(recipe)
                    let _ = controller.view
                }
                
                it("should have the recipe name") {
                    expect(controller.nameLabel.text).to(equal(recipe.name))
                }
                
                it("should have recipe information") {
                    expect(controller.informationLabel.text[0...20]).to(equal(recipe.information[0...20]))
                }
                
                it("should convert recipe information into markdown") {
                    expect(controller.informationLabel.text[0...20]).toNot(contain("http"))
                }
                
                it("should have recipe directions") {
                    expect(controller.directionsTextView.text).to(equal(recipe.directions))
                }
                
                it("should have recipe ingredients") {
                    var cells = [UITableViewCell]()
                    for recipeIndex in 0..<recipe.ingredients.count {
                        cells.append(controller.ingredientsTableView.tableView(controller.ingredientsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: recipeIndex, inSection: 0)))
                    }
                    expect(cells.count).to(equal(recipe.ingredients.count))
                    for ingredient in recipe.ingredients {
                        expect(cells.map({ $0.textLabel!.text! })).to(contain(ingredient.base!.name))
                    }
                }
                
                it("should have the recipe abv") {
                    expect(controller.subheadLabel.text).to(contain(Int(recipe.abv).description))
                }
                
                it("should show the source") {
                    expect(controller.informationLabel.text).to(contain("Fine Art of Mixing Drinks"))
                }
            }
        }
    }
}