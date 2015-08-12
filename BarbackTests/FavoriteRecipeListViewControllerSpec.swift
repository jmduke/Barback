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
                controller.viewDidAppear(true)
            }
            
            it("should have exactly one row for each favorited recipe") {
                let tableView = controller.tableView
                let numberOfRows = tableView.numberOfRowsInSection(0)
                let favoriteRecipes = Recipe.favorites()
                expect(numberOfRows).to(equal(favoriteRecipes.count))
            }
        }
        
    }
}