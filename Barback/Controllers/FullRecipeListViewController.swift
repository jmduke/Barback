//
//  FullRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class FullRecipeListViewController: RecipeListViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var searchBar: UISearchBar!

    override var viewTitle: String {
        get {
            return "Recipes"
        }
        set {
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController, willHideSearchResultsTableView tableView: UITableView) {
        recipes = Recipe.all()
        tableView.reloadData()
    }
    
    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController) {
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
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }

    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    func filterContentForSearchText(searchText: String) {
        recipes = Recipe.all().filter({
            $0.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ||
            (searchText.lowercaseString.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) > 2 &&
            $0.information?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil)
        })
        recipes.sort({
            $0.name.lowercaseString.rangeOfString(searchText.lowercaseString)?.startIndex >
            $1.name.lowercaseString.rangeOfString(searchText.lowercaseString)?.startIndex
        })
    }

    override func styleController() {
        super.styleController()

        UITextField.appearance().font = UIFont(name: UIFont.primaryFont(), size: 16.0)
        UITextField.appearance().textColor = Color.Dark.toUIColor()

        searchBar.backgroundImage = UIImage()
        searchBar.translucent = false   
        searchBar.barTintColor = UIColor.clearColor()
        searchBar.backgroundColor = UIColor.clearColor()
        searchBar.tintColor = Color.Background.toUIColor()
        searchDisplayController?.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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