import Foundation
import Barback
import UIKit
import Nimble
import Quick

class FlavorSpec: QuickSpec {
    
    override func spec() {
        
        var flavor: Flavor!
        
        describe("major bases") {
            
            it("should have at least one recipe of each flavor") {
                expect(IngredientBaseGroup.Gin.recipes.filter({ Flavor.Crisp.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Gin.recipes.filter({ Flavor.Sweet.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Gin.recipes.filter({ Flavor.Smoky.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Vodka.recipes.filter({ Flavor.Crisp.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Vodka.recipes.filter({ Flavor.Sweet.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Vodka.recipes.filter({ Flavor.Smoky.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Whiskey.recipes.filter({ Flavor.Crisp.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Whiskey.recipes.filter({ Flavor.Sweet.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Whiskey.recipes.filter({ Flavor.Smoky.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Tequila.recipes.filter({ Flavor.Crisp.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Tequila.recipes.filter({ Flavor.Sweet.describesRecipe($0) }).count).to(beGreaterThan(0))
                expect(IngredientBaseGroup.Tequila.recipes.filter({ Flavor.Smoky.describesRecipe($0) }).count).to(beGreaterThan(0))
            }
        }
        
        describe("a sweet flavor") {
            flavor = Flavor.Sweet
            
            it("should have a bunch of recipes") {
                expect(Recipe.all().filter({ flavor.describesRecipe($0) }).count).to(beGreaterThan(6))
            }
        }
        
        describe("a smoky flavor") {
            flavor = Flavor.Smoky
            
            it("should have a bunch of recipes") {
                expect(Recipe.all().filter({ flavor.describesRecipe($0) }).count).to(beGreaterThan(6))
            }
        }
        
        describe("a crisp flavor") {
            flavor = Flavor.Crisp
            
            it("should have a bunch of recipes") {
                expect(Recipe.all().filter({ flavor.describesRecipe($0) }).count).to(beGreaterThan(6))
            }
        }


    }
}