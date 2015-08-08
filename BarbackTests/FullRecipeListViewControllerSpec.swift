//
//  FullRecipeViewListControllerSpec.swift
//  Barback
//
//  Created by Justin Duke on 5/9/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

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
            
            context("when you toggle the sort") {
                it("should sort differenty") {
                    controller.toggleSortingMethod()
                    let tableView = controller.tableView
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    
                    expect(controller.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text).to(equal("Yellow Bird"))
                }
            }
        }

        
    }
}