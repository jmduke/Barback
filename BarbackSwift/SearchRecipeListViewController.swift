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
    
    var possibleIngredients: [IngredientBase] = [IngredientBase]()
        {
        didSet {
            let allRecipes = managedContext().objects(Recipe.self)!.filter(filterRecipes)
            recipesForPossibleIngredients = []
            for ingredient in possibleIngredients {
                recipesForPossibleIngredients.append(allRecipes.filter({self.recipeHasAllIngredients($0, ingredients: [ingredient])}).count)
            }
            possibleIngredients = possibleIngredients.sorted({self.recipesForPossibleIngredients[find(self.possibleIngredients, $0)!] > self.recipesForPossibleIngredients[find(self.possibleIngredients, $1)!]})
            recipesForPossibleIngredients = recipesForPossibleIngredients.sorted({$0 > $1})
            possibleIngredients = possibleIngredients.filter({self.recipesForPossibleIngredients[find(self.possibleIngredients, $0)!] > 0})
        }
    }
    var recipesForPossibleIngredients: [Int] = []
    
    
    var activeIngredients: [IngredientBase] = []


    var searchTerms: [String] = [String]() {
        didSet {
        activeIngredients = []
        for term in searchTerms {
            let ingredient = managedContext().objectForName(IngredientBase.self, name: term)
            if ingredient != nil {
                activeIngredients.append(ingredient!)
            }
        }
    }
    }

    func currentlyTypingIngredient() -> Bool {
        return managedContext().objectForName(IngredientBase.self, name: searchTerms.last ?? "N/A") == nil
    }
    
    override var viewTitle: String {
        get {
            return "Search"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.searchBar(searchBar, textDidChange: searchBar.text)
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
        
        // Empty state.
        
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
    
    func recipeHasAllIngredients(recipe: Recipe, ingredients: [IngredientBase]) -> Bool {
        let bases: [IngredientBase] = (recipe.ingredients.allObjects as [Ingredient]).map({$0.base})
        return ingredients.count == ingredients.filter({contains(bases, $0)}).count
    }

    override func filterRecipes(recipe: Recipe) -> Bool {
        return recipeHasAllIngredients(recipe, ingredients: activeIngredients)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if (!searchBar.text.hasSuffix(",") && !searchBar.text.isEmpty) {
            searchBar.text.append("," as Character)
        }
        
        self.searchBar(self.searchBar, textDidChange: searchBar.text)
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: NSString) {
        tableView.backgroundView = nil

        // Grab search bar text and the recipes that match it.
        let rawSearchTerms = searchBar.text.componentsSeparatedByString(",") as [NSString]
        searchTerms = rawSearchTerms.map({searchTerm in searchTerm.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())})
        if (currentlyTypingIngredient()) {
            let newestIngredient = rawSearchTerms.last!
            if newestIngredient == "" {
                possibleIngredients = managedContext().objects(IngredientBase.self)!
            } else {
                let predicate = NSPredicate(format: "name CONTAINS[cd] \"\(newestIngredient)\"")
                possibleIngredients = managedContext().objects(IngredientBase.self, predicate: predicate)!
            }
            possibleIngredients = possibleIngredients.filter({!contains(self.activeIngredients, $0)})
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


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (!currentlyTypingIngredient()) {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        } else {

            let ingredient = possibleIngredients[indexPath.row]
            let cellIdentifier = "recipeCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            let labelPrefix = join("", activeIngredients.map({ $0.name + ", " }))
            cell.textLabel?.text = "\(labelPrefix)\(ingredient.name)"
            cell.detailTextLabel?.text = "\(recipesForPossibleIngredients[indexPath.row]) recipes"
            cell.stylePrimary()
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if (!currentlyTypingIngredient()) {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return possibleIngredients.count
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !currentlyTypingIngredient() {
            return
        }
        let selectedRow = tableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        let ingredient =  possibleIngredients[rowIndex!]
        let labelPrefix = join("", activeIngredients.map({ $0.name + "," }))
        searchBar.text = "\(labelPrefix)\(ingredient.name)"
        searchBar(searchBar, textDidChange: searchBar.text)
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        return !currentlyTypingIngredient()
    }
}