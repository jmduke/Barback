import Foundation
import Barback
import UIKit
import Nimble
import Quick

class SearchRecipeListViewControllerSpec: QuickSpec {
    
    override func spec() {
        
        describe("a search recipe list controller") {
            
            var controller: SearchRecipeListViewController!
            beforeEach {
                controller = SearchRecipeListViewController()
                controller.activeIngredients = []
            }
            
            it("should have exactly one row for each base") {
                let tableView = controller.tableView
                let numberOfRows = tableView.numberOfRowsInSection(0)
                let usedBases = IngredientBase.all().filter({ $0.uses.count > 0 })
                expect(numberOfRows).to(equal(usedBases.count))
            }
            
            it("should start out sorted alphabetically") {
                let tableView = controller.tableView
                
                var indexPath = NSIndexPath(forRow: 0, inSection: 0)
                expect(controller.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text).to(equal("7-Up"))

                indexPath = NSIndexPath(forRow: 1, inSection: 0)
                expect(controller.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text).to(equal("Absinthe"))
            }
            
            it("should indicate how many recipes each ingredient has") {
                let tableView = controller.tableView
                let usedBases = IngredientBase.all().filter({ $0.uses.count > 0 }).sort({ $0.name < $1.name })
                for (index, base) in usedBases.enumerate() {
                    let recipeCount = base.uses.count
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    expect(controller.tableView(tableView, cellForRowAtIndexPath: indexPath).detailTextLabel!.text).to(contain("\(recipeCount)"))
                }
            }
            
        }

    }
}