//
//  FullRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

public class FullRecipeListViewController: RecipeListViewController, UISearchBarDelegate, HasCoachMarks {

    override public var recipes : [Recipe] {
        didSet {
            if (searchController != nil && searchController!.searchBar.text!.isEmpty) {
                super.recipes = recipes.sort(sortingMethod.sortFunction())
            }
        }
    }

    override var viewTitle: String {
        get {
            return "Recipes"
        }
        set {
        }
    }

    var sortingMethod: RecipeSortingMethod = RecipeSortingMethod.NameDescending
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        recipes = Recipe.all()
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }

    public func toggleSortingMethod() {
        let nextSortingMethodRawValue = (sortingMethod.rawValue + 1) % RecipeSortingMethod.maximum()
        sortingMethod = RecipeSortingMethod(rawValue: nextSortingMethodRawValue)!
        recipes = recipes.sort(sortingMethod.sortFunction())
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        self.navigationItem.leftBarButtonItem!.title = sortingMethod.title()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.definesPresentationContext = true
        
        attachSearchBar()

        let sortButton = UIBarButtonItem(title: sortingMethod.title(), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSortingMethod")
        self.navigationItem.leftBarButtonItem = sortButton

        runCoachMarks(view)
    }

    override func getSelectedRecipe() -> Recipe {
        let selectedRow = tableView.indexPathForSelectedRow
        let row = selectedRow?.row
        return recipes[row!]
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = cellForRecipe(recipes[indexPath.row], andIndexPath: indexPath) as! RecipeCell
        if (searchController!.active) {
            cell.highlightText(searchController!.searchBar.text!)
        }
        return cell
    }
    
    func coachMarksForController() -> [CoachMark] {
        return [
            CoachMark(rect: tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)), caption: "Recipes.  (The good stuff.)"),
            CoachMark(rect: (self.searchController?.searchBar.frame)!, caption: "Search recipes by name or description.")
        ]
    }

}