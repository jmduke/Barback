import Foundation
import Barback
import UIKit
import Nimble
import Quick

class FavoriteRecipeListViewControllerSpec: QuickSpec {
    
    override func spec() {
        
        describe("a favorite recipe list controller") {
            
            var controller: FavoriteRecipeListViewController!
            beforeEach {
                controller = FavoriteRecipeListViewController()
                let _ = controller.view
                controller.viewWillAppear(true)
            }
            
            it("should have exactly one row for each favorited recipe") {
                let tableView = controller.tableView
                let numberOfRows = tableView.numberOfRowsInSection(0)
                let favoriteRecipes = Recipe.favorites()
                expect(numberOfRows).to(equal(favoriteRecipes.count))
            }
            
            it("should show a shopping list view button") {
                let tableView = controller.tableView
                let footer = tableView.tableFooterView!
                let button = footer.subviews.first as! UIButton
                expect(button.titleLabel?.text).to(contain("Shopping"))
            }
        }
        
    }
}