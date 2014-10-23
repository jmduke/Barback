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
    
    @IBOutlet var searchBar: UISearchBar!
    
    var searchTerms = [String]()
    
    override var viewTitle: String {
        get {
            return "Search"
        }
    }
    
    override func styleController() {
        super.styleController()
        
        searchBar.translucent = false
        searchBar.barTintColor = UIColor.darkColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow us to actually pick up search bar input.
        searchBar.delegate = self
        
        // Initialize the filter function.
        searchBar(searchBar, textDidChange: searchBar.text)
        
        // So we hide the keyboard when we tap away from it.
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        loadCoachMarks()
    }
    
    func loadCoachMarks() {
        let searchBarPosition = searchBar.bounds
        
        let searchBarCaption = "Type stuff in here to search for ingredients (\"vermouth\", \"orange,vodka\"), recipe names (\"punch\")."
        
        let coachMarks = [["rect": NSValue(CGRect: searchBarPosition), "caption": searchBarCaption]]
        runCoachMarks(coachMarks)
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    override func filterRecipes(recipe: Recipe) -> Bool {
        return recipe.matchesTerms(searchTerms) && recipe.isReal
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: NSString) {
        
        // Grab search bar text and the recipes that match it.
        let rawSearchTerms = searchBar.text.componentsSeparatedByString(",") as [NSString]
        searchTerms = rawSearchTerms.map({searchTerm in searchTerm.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())})
        
        if searchTerms.isEmpty || searchTerms[0].isEmpty {
            recipes = []
            let emptyStateLabel = UILabel(frame: tableView.frame)
            let randomRecipe = managedContext().randomObject(IngredientBase.self)
            emptyStateLabel.text = "Try searching for \(randomRecipe!.name)."
            
            // Style it up here.
            emptyStateLabel.textAlignment = NSTextAlignment.Center
            emptyStateLabel.textColor = UIColor.lighterColor()
            emptyStateLabel.numberOfLines = 3
            emptyStateLabel.font = UIFont(name: UIFont.primaryFont(), size: 24)
            tableView.backgroundView = emptyStateLabel
        } else {
            recipes = managedContext().objects(Recipe.self)!.filter(filterRecipes)
            tableView.backgroundView = nil
        }
        
        // Allow a random choice!
        if (recipes.count > 1) {
            recipes.append(managedContext().objectForName(Recipe.self, name: "Bartender's Choice")!)
        }
        
        tableView.reloadData()
    }
}