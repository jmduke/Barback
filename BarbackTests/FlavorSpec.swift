import Foundation
import Barback
import UIKit
import Nimble
import Quick

class FlavorSpec: QuickSpec {
    
    override func spec() {
        
        var flavor: Flavor!
        
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