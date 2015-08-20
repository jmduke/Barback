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
            
            context("when it has an active ingredient") {
                var base: IngredientBase!
                beforeEach {
                    base = IngredientBase.all().filter({ $0.name == "Rye" }).first!
                    controller.activeIngredients = [base]
                    let _ = controller.view
                    controller.viewWillAppear(true)
                }

                it("should have still only have one row for each base") {
                    let tableView = controller.tableView
                    tableView.reloadData()
                    
                    var allBases = [IngredientBase]()
                    Recipe.all().map({
                        (r: Recipe) in
                        r.ingredients.map({ $0.base! })
                    }).filter({
                        (l: [IngredientBase]) in
                        l.contains(base)
                    }).map({
                        (l: [IngredientBase]) in
                        l.map({ allBases.append($0) })
                    })
                    let uniqueBases = Set(allBases.filter({ $0 != base }).map({ $0.name}))
                    let numberOfRows = tableView.numberOfRowsInSection(0)
                    expect(numberOfRows).to(equal(uniqueBases.count))
                }
                
                it("should not show that active ingredient") {
                    let tableView = controller.tableView
                    tableView.reloadData()
                    let rowCount = tableView.numberOfRowsInSection(0) - 1
                    for row in 0...(rowCount) {
                        let indexPath = NSIndexPath(forRow: row, inSection: 0)
                        expect(controller.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text).toNot(contain("\(base.name)"))
                    }
                }
                
                
                it("should prompt to view recipes") {
                    let tableView = controller.tableView
                    expect(tableView.tableHeaderView).toNot(beNil())
                    expect(tableView.tableHeaderView?.subviews.count).to(equal(2))
                    let headerText = (tableView.tableHeaderView!.subviews.first! as! UIButton).titleLabel?.text
                    expect(headerText).to(contain("recipes"))
                    expect(headerText).to(contain("\(base.uses.count)"))
                }
                
            }
            
        }

    }
}