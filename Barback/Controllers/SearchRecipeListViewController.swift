//
//  SearchRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class SearchRecipeListViewController: RecipeListViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!

    var allRecipes: [Recipe] = [Recipe]()
    var searchBarFocused: Bool = false

    var possibleIngredients: [IngredientBase] = [IngredientBase]()
        {
        didSet {
            let currentRecipes = allRecipes.filter(filterRecipes)
            recipesForPossibleIngredients = Array(count: possibleIngredients.count, repeatedValue: 0)
            for recipe in currentRecipes {
                for ingredient in recipe.ingredients {
                    let base = ingredient.base
                    if contains(possibleIngredients, base) {
                        recipesForPossibleIngredients[find(possibleIngredients, base)!] += 1
                    }
                }
            }
            
            // Sorting is very slow, which is why we do this like this.  Yes, it is very ugly.
            var positionsInArray: [IngredientBase: Int] = [:]
            for pos in 0..<possibleIngredients.count {
                positionsInArray[possibleIngredients[pos]] = self.recipesForPossibleIngredients[pos]
            }
            
            // Fun fact: this is by far the slowest part of this entire codebase.
            possibleIngredients = possibleIngredients.filter({positionsInArray[$0]! > 0})
            possibleIngredients.sort({positionsInArray[$0]! > positionsInArray[$1]!})
            recipesForPossibleIngredients.sort({$0 > $1})
        }
    }
    var recipesForPossibleIngredients: [Int] = []
    
    
    var activeIngredients: [IngredientBase] = []


    var searchTerms: [String] = [String]() {
        didSet {
        activeIngredients = []
        for term in searchTerms {
            let ingredient = IngredientBase.forName(term)
            if ingredient != nil && !(term == searchTerms.last! && currentlyTypingIngredient()) {
                activeIngredients.append(ingredient!)
            }
        }
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
        self.searchBar(searchBar, textDidChange: searchString)
        return true
    }

    func currentlyTypingIngredient() -> Bool {
        let typingIncompleteIngredient = IngredientBase.forName(searchTerms.last ?? "N/A") == nil
        return typingIncompleteIngredient
    }
    
    override var viewTitle: String {
        get {
            return "Ingredients"
        }
        set {
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if searchBar.text != "" {
            self.searchBar(searchBar, textDidChange: searchBar.text)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Run this in viewDidLoad instead of making it a `let` so it gets loaded
        // after core data initialization.
        allRecipes = Recipe.all()
        
        // Allow us to actually pick up search bar input.
        searchBar.delegate = self

        // So we hide the keyboard when we tap away from it.
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        // Initialize the filter function.
        searchBar(searchBar, textDidChange: searchBar.text)
    }
    
    override func viewDidLayoutSubviews() {
        loadCoachMarks()
    }
    
    func loadCoachMarks() {
        let searchBarPosition = searchBar.bounds
        
        let searchBarCaption = "Type stuff in here to search for ingredients (\"vermouth\", \"orange + vodka\")."
        
        let coachMarks = [["rect": NSValue(CGRect: searchBarPosition), "caption": searchBarCaption]]
        runCoachMarks(coachMarks)
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }

    override func filterRecipes(recipe: Recipe) -> Bool {
        return activeIngredients.filter({ recipe.usesIngredient($0) }).count == activeIngredients.count
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBarFocused = true
        if (!searchBar.text.hasSuffix(" + ") && !searchBar.text.isEmpty) {
            searchBar.text = searchBar.text + " + "
        }
        
        self.searchBar(self.searchBar, textDidChange: searchBar.text)
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: NSString) {

        // Grab search bar text and the recipes that match it.
        let rawSearchTerms = searchBar.text.componentsSeparatedByString(" + ") as [NSString]
        searchTerms = rawSearchTerms.map({searchTerm in searchTerm.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())})
        if (currentlyTypingIngredient()) {
            let newestIngredient = rawSearchTerms.last!
            
            var allPossibleIngredients: [IngredientBase]
            if newestIngredient == "" {
                allPossibleIngredients = IngredientBase.all()
            } else {
                allPossibleIngredients = IngredientBase.nameContainsString(newestIngredient)
            }
            if allPossibleIngredients.filter({!contains(self.activeIngredients, $0)}).count != possibleIngredients.count {
                possibleIngredients = allPossibleIngredients.filter({!contains(self.activeIngredients, $0)})
            }
        } else {
            recipes = allRecipes.filter(filterRecipes).sorted({ $0.name < $1.name })
        }
        
        if (currentlyTypingIngredient() && possibleIngredients.isEmpty) {
            let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
            emptyStateLabel.text = "Sorry -- we don't know what \(searchTerms.last!) is!"
            tableView.backgroundView = emptyStateLabel
        } else if (recipes.isEmpty) {
            let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
            emptyStateLabel.text = "Sorry -- no recipes with these ingredients."
            tableView.backgroundView = emptyStateLabel
        } else {
            tableView.backgroundView = nil
        }
        
        // Allow a random choice!
        if (recipes.count > 1) {
            recipes.append(Recipe.forName("Bartender's Choice")!)
        }
    
        tableView.reloadData()
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (!currentlyTypingIngredient()) {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        } else {

            let ingredient = possibleIngredients[indexPath.row]
            let cellIdentifier = "recipeCell"
            let cell = StyledCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
            
            let labelPrefix = join("", activeIngredients.map({ $0.name + " + " }))
            
            cell.textLabel?.text = "\(labelPrefix)\(ingredient.name)"
            if (!searchTerms.last!.isEmpty) {
                cell.highlightText(searchTerms.last!)
            }
            
            let designator = recipesForPossibleIngredients[indexPath.row] > 1 ? "recipes" : "recipe"
            cell.detailTextLabel?.text = "\(recipesForPossibleIngredients[indexPath.row]) \(designator)"
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if (!currentlyTypingIngredient()) {
            print("BAH")
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            print("SHHH")
            return possibleIngredients.count
        }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !currentlyTypingIngredient() {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
            return
        }
        let selectedRow = tableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        let ingredient =  possibleIngredients[rowIndex!]
        let labelPrefix = join("", activeIngredients.map({ $0.name + " + " }))
        searchBar.text = "\(labelPrefix)\(ingredient.name)"
        searchBarFocused = false
        searchBar(searchBar, textDidChange: searchBar.text)
        
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return !currentlyTypingIngredient()
    }
}