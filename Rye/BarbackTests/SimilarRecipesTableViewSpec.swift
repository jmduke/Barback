import Foundation
import Barback
import UIKit
import Nimble
import Quick


class SimilarRecipeTableViewSpec: QuickSpec {
    override func spec() {
        
        describe("an table with no similar recipes") {
            let tableView = SimilarRecipeTableView()
            tableView.recipe = Recipe.forName("Long Island Iced Tea")
            
            it("should be hidden") {
                expect(tableView.hidden).to(equal(false))
            }
        }
    }
}