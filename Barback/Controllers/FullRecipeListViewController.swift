//
//  FullRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

public class FullRecipeListViewController: RecipeListViewController, UISearchResultsUpdating, UISearchBarDelegate, HasCoachMarks {

    var searchController: UISearchController?

    override public var recipes : [Recipe] {
        didSet {
            if (searchController != nil && searchController!.searchBar.text!.isEmpty) {
                super.recipes = recipes.sort(sortingMethod.sortFunction())
            }
        }
    }

    public func updateSearchResultsForSearchController(searchController: UISearchController) {
        if (!searchController.searchBar.text!.isEmpty) {
            self.filterContentForSearchText(searchController.searchBar.text!)
        } else {
            recipes = Recipe.all()
        }
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
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

    func filterContentForSearchText(searchText: String) {
        recipes = Recipe.all().filter({
            $0.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ||
            (searchText.lowercaseString.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) > 2 &&
            $0.information.lowercaseString.rangeOfString(searchText.lowercaseString) != nil)
        })
        recipes.sortInPlace({
            let firstLocation = $0.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            let secondLocation = $1.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            return firstLocation?.startIndex > secondLocation?.startIndex
        })
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

        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController!.searchResultsUpdater = self
        self.searchController!.searchBar.scopeButtonTitles = []
        self.searchController!.dimsBackgroundDuringPresentation = false
        self.searchController!.hidesNavigationBarDuringPresentation = false

        self.searchController!.searchBar.styleSearchBar()

        self.tableView.tableHeaderView = UIView(frame: self.searchController!.searchBar.frame)
        self.tableView.tableHeaderView!.addSubview(self.searchController!.searchBar)
        self.searchController!.searchBar.sizeToFit()


        let sortButton = UIBarButtonItem(title: sortingMethod.title(), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSortingMethod")
        self.navigationItem.leftBarButtonItem = sortButton

        if recipes.count == 0 {
            let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
            emptyStateLabel.text = "Connect to the internet to grab recipes!"
            tableView.backgroundView = emptyStateLabel
        }
        
        runCoachMarks()
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
            CoachMark(rect: (self.searchController?.searchBar.frame)!, caption: "Search recipes by name or description."),
            CoachMark(rect: (self.navigationItem.leftBarButtonItem?.valueForKey("view") as! UIView).frame, caption: "Search recipes by name or description.")
        ]
    }

}