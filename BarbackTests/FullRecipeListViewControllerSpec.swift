import Foundation
import Barback
import UIKit
import Nimble
import Quick

class FullRecipeListViewControllerSpec: QuickSpec {

    override func spec() {

        describe("a full recipe list controller") {
            
            var controller: FullRecipeListViewController!
            beforeEach {
                controller = FullRecipeListViewController()
                controller.recipes = Recipe.all()
            }
            
            it("should have all recipes") {
                let tableView = controller.tableView
                expect(controller.tableView(tableView, numberOfRowsInSection: 0)).to(equal(Recipe.all().count))
            }
            
            it("should start out sorted alphabetically") {
                let tableView = controller.tableView
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                
                expect(controller.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text).to(equal("20th Century"))
            }
            
            context("when you search") {
                let searchText = "Man"
                beforeEach {
                    let _ = controller.viewDidLoad()
                    controller.searchController!.searchBar.text = searchText
                }
                
                it("should only show recipes with the search term") {
                    expect(controller.tableView(controller.tableView, numberOfRowsInSection: 0)).to(equal(Recipe.all().filter({
                        $0.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ||
                            $0.information.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
                    }).count))
                }

                it("should only show recipes with the search term in the name first") {
                    let tableView = controller.tableView
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    
                    expect(controller.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text!.lowercaseString).to(contain(searchText.lowercaseString))
                }
                
                it("should only show recipes with the search term in the name first, first") {
                    let tableView = controller.tableView
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    
                    expect(controller.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text).to(equal("Manhattan"))
                }
            }
        }

        
    }
}