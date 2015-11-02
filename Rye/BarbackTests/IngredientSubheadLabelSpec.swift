import Foundation
import Barback
import UIKit
import Nimble
import Quick

class IngredientSubheadLabelSpec: QuickSpec {
    
    override func spec() {
        
        describe("a standard subhead label") {
            let base = IngredientBase.all().filter({ $0.name == "Vodka" }).first!
            let subheadLabel = IngredientSubheadLabel()
            subheadLabel.ingredient = base
            
            it("should mention the abv") {
                let abv = base.abv
                expect(subheadLabel.text).to(contain("\(abv)"))
            }
            
            it("should mention the type of ingredient") {
                let type = base.ingredientType
                expect(subheadLabel.text).to(contain(type.rawValue))
            }
        }
        
        describe("a subhead label for a non-alcoholic ingredient") {
            let base = IngredientBase.all().filter({ $0.abv == 0 }).first!
            let subheadLabel = IngredientSubheadLabel()
            subheadLabel.ingredient = base
            
            it("should mention that it's non-alcoholic") {
                expect(subheadLabel.text).to(contain("non-alcoholic"))
            }
        }
        
    }
}