//
//  FullRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit


enum SortingMethod: Int {
    case ABVDescending = 0
    case ABVAscending
    case ComplexityDescending
    case ComplexityAscending
    case NameDescending
    case NameAscending

    static func maximum() -> Int {
        // from http://stackoverflow.com/questions/26261011/swift-chose-a-random-enumeration-value
        var maxValue: Int = 0
        while let _ = self.init(rawValue: ++maxValue as Int) {}
        return maxValue
    }

    func title() -> String {
        return ["ABV", "Complexity", "Name"][rawValue / 2] + ["↓", "↑"][rawValue % 2]
    }

    func sortFunction() -> ((Recipe, Recipe) -> Bool) {
        func sortByABV(isDescending: Bool) -> ((Recipe, two: Recipe) -> Bool) {
            func ascending(one: Recipe, two: Recipe) -> Bool { return one.abv < two.abv }
            func descending(one: Recipe, two: Recipe) -> Bool { return one.abv > two.abv }
            return (isDescending ? descending : ascending)
        }
        func sortByComplexity(isDescending: Bool) -> ((Recipe, two: Recipe) -> Bool) {
            func ascending(one: Recipe, two: Recipe) -> Bool { return one.ingredients.count < two.ingredients.count }
            func descending(one: Recipe, two: Recipe) -> Bool { return one.ingredients.count > two.ingredients.count }
            return (isDescending ? descending : ascending)
        }
        func sortByName(isDescending: Bool) -> ((Recipe, two: Recipe) -> Bool) {
            func ascending(one: Recipe, two: Recipe) -> Bool { return one.name.lowercaseString > two.name.lowercaseString }
            func descending(one: Recipe, two: Recipe) -> Bool { return one.name.lowercaseString < two.name.lowercaseString }
            return (isDescending ? descending : ascending)
        }

        switch self {
        case .ABVDescending:
            return sortByABV(true)
        case .ABVAscending:
            return sortByABV(false)
        case .ComplexityDescending:
            return sortByComplexity(true)
        case .ComplexityAscending:
            return sortByComplexity(false)
        case .NameDescending:
            return sortByName(true)
        case .NameAscending:
            return sortByName(false)
        }
    }
}

public class FullRecipeListViewController: RecipeListViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var searchController: UISearchController?

    override public var recipes : [Recipe] {
        didSet {
            super.recipes = recipes.sort(sortingMethod.sortFunction())
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

    override public func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (searchController != nil && searchController!.active) {
            // searchController?.
        }
        super.prepareForSegue(segue, sender: sender)
    }

    var sortingMethod: SortingMethod = SortingMethod.NameDescending

    
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
            $0.name.lowercaseString.rangeOfString(searchText.lowercaseString)?.startIndex >
                $1.name.lowercaseString.rangeOfString(searchText.lowercaseString)?.startIndex
        })
    }

    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    public func toggleSortingMethod() {
        let nextSortingMethodRawValue = (sortingMethod.rawValue + 1) % SortingMethod.maximum()
        sortingMethod = SortingMethod(rawValue: nextSortingMethodRawValue)!
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

}