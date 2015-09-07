import Foundation
import Barback
import UIKit
import Nimble
import Quick

class AdjectiveSpec: QuickSpec {
    
    override func spec() {
        
        var adjective: Adjective!
        
        describe("bold recipes") {
            adjective = Adjective.Bold
            
            it("should have a bunch") {
                expect(Recipe.all().filter({ adjective.describesRecipe($0) }).count).to(beGreaterThan(6))
            }
        }
        
        describe("bubbly recipes") {
            adjective = Adjective.Daring
            
            it("should have a bunch") {
                expect(Recipe.all().filter({ adjective.describesRecipe($0) }).count).to(beGreaterThan(6))
            }
        }
        
        describe("silly recipes") {
            adjective = Adjective.Silly
            
            it("should have a bunch") {
                expect(Recipe.all().filter({ adjective.describesRecipe($0) }).count).to(beGreaterThan(6))
            }
        }
        
        describe("quiet recipes") {
            adjective = Adjective.Quiet
            
            it("should have a bunch") {
                expect(Recipe.all().filter({ adjective.describesRecipe($0) }).count).to(beGreaterThan(6))
            }
        }
        
        describe("thirsty recipes") {
            adjective = Adjective.Thirsty
            
            it("should have a bunch") {
                expect(Recipe.all().filter({ adjective.describesRecipe($0) }).count).to(beGreaterThan(6))
            }
        }
        
        
    }
}