//
//  SearchRecipeListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class SearchRecipeListViewController: RecipeListViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar
    
    override var viewTitle: String {
    get {
        return "Search"
    }
    }
    
    override func styleController() {
        super.styleController()
        
        self.searchBar.translucent = false
        self.searchBar.barTintColor = UIColor().darkColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow us to actually pick up search bar input.
        self.searchBar.delegate = self
        
        // Initialize the filter function.
        self.searchBar(self.searchBar, textDidChange: self.searchBar.text)
        
        // So we hide the keyboard when we tap away from it.
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    
    /*
        override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return recipes.count + 1
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if indexPath.row < recipes.count {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        // Otherwise, we return the option to pick randomly!
        
        
    }*/
    
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    override func filterRecipes(recipe: Recipe) -> Bool {
        var searchTerms = self.searchBar.text.componentsSeparatedByString(",") as NSString[]
        searchTerms = searchTerms.map({searchTerm in searchTerm.lowercaseString})
        return recipe.matchesTerms(searchTerms)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: NSString) {
        super.viewDidLoad()
        if (recipes.count > 1) {
            recipes.append(Recipe(name: "Bartender's Choice", directions: "", glassware: "", ingredients: Ingredient[]()))
        }
        self.tableView.reloadData()
    }
}