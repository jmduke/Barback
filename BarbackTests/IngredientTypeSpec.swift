import Foundation
import Barback
import UIKit
import Nimble
import Quick

class IngredientTypeSpec: QuickSpec {

    override func spec() {

        let types = IngredientType.allValues
        
        describe("all ingredients") {
        
            let bases = IngredientBase.all()
        
            it("should have flavors") {
                for base in bases {
                    expect(types).to(contain(base.ingredientType))
                }
            }
        }
        
        describe("all types") {
            it("should be pluralized correctly") {
                expect(IngredientType.Mixer.pluralize()).to(equal("mixers"))
                expect(IngredientType.Garnish.pluralize()).to(equal("garnishes"))
            }
        }
    }
}