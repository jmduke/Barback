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
        while let _ = self(rawValue: ++maxValue as Int) {}
        return maxValue
    }
    
    func title() -> String {
        return ["ABV", "Complexity", "Name"][rawValue / 2] + ["↓", "↑"][rawValue % 2]
    }
    
    func sortFunction() -> ((Recipe, Recipe) -> Bool) {
        func sortByABV(isDescending: Bool) -> ((one: Recipe, two: Recipe) -> Bool) {
            func ascending(one: Recipe, two: Recipe) -> Bool { return one.abv < two.abv }
            func descending(one: Recipe, two: Recipe) -> Bool { return one.abv > two.abv }
            return (isDescending ? descending : ascending)
        }
        func sortByComplexity(isDescending: Bool) -> ((one: Recipe, two: Recipe) -> Bool) {
            func ascending(one: Recipe, two: Recipe) -> Bool { return one.ingredients.count < two.ingredients.count }
            func descending(one: Recipe, two: Recipe) -> Bool { return one.ingredients.count > two.ingredients.count }
            return (isDescending ? descending : ascending)
        }
        func sortByName(isDescending: Bool) -> ((one: Recipe, two: Recipe) -> Bool) {
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

class FullRecipeListViewController: RecipeListViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var searchBar: UISearchBar!

    override var viewTitle: String {
        get {
            return "Recipes"
        }
        set {
        }
    }
    
    var sortingMethod: SortingMethod = SortingMethod.NameAscending
    
    func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController) {
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    func searchDisplayControllerWillEndSearch(controller: UISearchDisplayController) {
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    
    func searchDisplayController(controller: UISearchDisplayController, willHideSearchResultsTableView tableView: UITableView) {
        recipes = Recipe.all()
        tableView.reloadData()
    }
    
    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController) {
        if (self.tableView != self.searchDisplayController!.searchBar.superview) {
            self.tableView.insertSubview(self.searchDisplayController!.searchBar, aboveSubview:self.tableView)
        }
        recipes = Recipe.all()
        tableView.reloadData()
    }
    
    func searchDisplayController(controller: UISearchDisplayController, willUnloadSearchResultsTableView tableView: UITableView) {
        recipes = Recipe.all()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        recipes = Recipe.all()
        tableView.reloadData()
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }

    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    func filterContentForSearchText(searchText: String) {
        recipes = Recipe.all().filter({
            $0.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ||
            (searchText.lowercaseString.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) > 2 &&
            $0.information?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil)
        })
        recipes = sorted(recipes, sortingMethod.sortFunction())
    }
    
    func showSearchBar() {
        self.searchBar.becomeFirstResponder()
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func toggleSortingMethod() {
        let nextSortingMethodRawValue = (sortingMethod.rawValue + 1) % SortingMethod.maximum()
        sortingMethod = SortingMethod(rawValue: nextSortingMethodRawValue)!
        recipes = sorted(recipes, sortingMethod.sortFunction())
        self.tableView.reloadData()
        self.navigationItem.leftBarButtonItem!.title = sortingMethod.title()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentOffset = CGPointMake(0,  self.searchBar.frame.size.height - self.tableView.contentOffset.y)
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "showSearchBar")
        self.navigationItem.rightBarButtonItem = searchButton
        
        // TODO: better icon.
        let sortButton = UIBarButtonItem(title: sortingMethod.title(), style: UIBarButtonItemStyle.Bordered, target: self, action: "toggleSortingMethod")
        self.navigationItem.leftBarButtonItem = sortButton
        
        let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
        emptyStateLabel.text = "Sorry, we can't get you recipes until you connect to the internet!"
        tableView.backgroundView = emptyStateLabel
        
        let reachability = Reachability.reachabilityForInternetConnection()
        reachability.reachableBlock = {
            (r: Reachability!) -> Void in
            let _ = Async.main {
                let hud = MBProgressHUD(view: self.view)
                self.view.addSubview(hud)
                hud.labelText = "Fetching you some great recipes."
                hud.show(true)
            }.background {
                while (!isAppSyncedThisLaunch()) {
                    continue
                }}.main {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.recipes = Recipe.all()
                    self.tableView.reloadData()
                }
        }
        reachability.startNotifier()
    }
    
    override func getSelectedRecipe() -> Recipe {
        let selectedRow = tableView.indexPathForSelectedRow()
        var row = selectedRow?.row
        if (searchDisplayController!.active) {
            let controller = self.searchDisplayController
            let view = controller?.searchResultsTableView
            row = view?.indexPathForSelectedRow()?.row
        }
        return recipes[row!]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = cellForRecipe(recipes[indexPath.row], andIndexPath: indexPath) as RecipeCell
        if (searchDisplayController!.active) {
            cell.highlightText(searchBar.text)
        }
        return cell
    }

}