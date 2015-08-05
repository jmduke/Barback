//
//  RecipeSpec.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import Barback
import UIKit
import Nimble
import Quick

class RecipeSpec: QuickSpec {

    override func spec() {

        describe("a recipe") {
            
            var recipe: Recipe!
            beforeEach {
                recipe = Recipe.all().filter({ $0.name == "Manhattan" })[0]
            }
            
            it("should have an abv") {
                expect(recipe.abv).to(beCloseTo(30.0, within: 10.0))
            }
        }
    }

}
