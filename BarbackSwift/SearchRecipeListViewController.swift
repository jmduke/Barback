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
    
    var searchTerms = String[]()
    
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
        
        loadCoachMarks()
    }
    
    func loadCoachMarks() {
        let searchBarPosition = self.searchBar.bounds
        let searchBarCaption = "Type stuff in here to search for ingredients (\"vermouth\", \"orange,vodka\"), recipe names (\"punch\")."
        
        let coachMarks = [["rect": NSValue(CGRect: searchBarPosition), "caption": searchBarCaption]]
        runCoachMarks(coachMarks)
    }
    
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    override func filterRecipes(recipe: Recipe) -> Bool {
        return recipe.matchesTerms(self.searchTerms)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: NSString) {
        let rawSearchTerms = self.searchBar.text.componentsSeparatedByString(",") as NSString[]
        self.searchTerms = rawSearchTerms.map({searchTerm in searchTerm.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())})

        self.recipes = self.allRecipes.filter(filterRecipes)
        if (recipes.count > 1) {
            recipes.append(Recipe(name: "Bartender's Choice", directions: "", glassware: "", ingredients: Ingredient[]()))
        }
        self.tableView.reloadData()
    }
}