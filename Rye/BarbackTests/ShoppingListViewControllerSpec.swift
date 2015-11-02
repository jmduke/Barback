import Foundation
import Barback
import UIKit
import Nimble
import Quick

class ShoppingListViewControllerSpec: QuickSpec {
    
    override func spec() {
        
        describe("a shopping list view controller") {
            
            var controller: ShoppingListViewController!
            beforeEach {
                controller = ShoppingListViewController()
                controller.ingredients = []
            }
            
            it("should have the correct title") {
                expect(controller.viewTitle).to(equal("Shopping List"))
            }
            
            context("with four bases of three types") {
                beforeEach {
                    controller.ingredients = [
                        IngredientBase.forName("Rye")!,
                        IngredientBase.forName("Vodka")!,
                        IngredientBase.forName("Orange juice")!,
                        IngredientBase.forName("Celery salt")!
                    ]
                }
                
                it("should have three sections") {
                    let tableView = controller.tableView
                    expect(tableView.numberOfSections).to(equal(3))
                }
                
                it("should have the correct number of rows, separate and total") {
                    let tableView = controller.tableView
                    expect(tableView.numberOfRowsInSection(0)).to(equal(2))
                    expect(tableView.numberOfRowsInSection(1)).to(equal(1))
                    expect(tableView.numberOfRowsInSection(2)).to(equal(1))
                }
            }
        }
    }
}