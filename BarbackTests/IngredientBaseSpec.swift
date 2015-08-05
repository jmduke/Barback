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

class IngredientBaseSpec: QuickSpec {

    override func spec() {

        describe("an ingredient base") {
            
            var base: IngredientBase!
            beforeEach {
                base = IngredientBase.all().filter({ $0.name == "Rye" })[0]
            }
            
            it("should have an abv") {
                expect(base.abv).to(beCloseTo(40.0, within: 10.0))
            }
        }
    }

}
