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
    
    let allRecipes = managedContext().objects(Recipe.self)!
    
    var possibleIngredients: [IngredientBase] = [IngredientBase]()
        {
        didSet {
            let currentRecipes = allRecipes.filter(filterRecipes)
            recipesForPossibleIngredients = Array(count: possibleIngredients.count, repeatedValue: 0)
            for recipe in currentRecipes {
                for ingredient in recipe.ingredients.allObjects as [Ingredient] {
                    let base = ingredient.base
                    if contains(possibleIngredients, base) {
                        recipesForPossibleIngredients[find(possibleIngredients, base)!] += 1
                    }
                }
            }
            
            // Sorting is very slow, which is why we do this like this.  Yes, it is very ugly.
            var positionsInArray: [IngredientBase: Int] = [:]
            for pos in 0..<possibleIngredients.count {
                positionsInArray[possibleIngredients[pos]] = pos
            }
            
            // Fun fact: this is by far the slowest part of this entire codebase.
            possibleIngredients = possibleIngredients.filter({self.recipesForPossibleIngredients[positionsInArray[$0]!] > 0})
            possibleIngredients.sort({self.recipesForPossibleIngredients[positionsInArray[$0]!] > self.recipesForPossibleIngredients[positionsInArray[$1]!]})
            recipesForPossibleIngredients.sort({$0 > $1})
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
        if searchBar.text != "" {
            self.searchBar(searchBar, textDidChange: searchBar.text)
        }
    }
    
    override func styleController() {
        super.styleController()
        
        searchBar.translucent = false
        searchBar.barTintColor = UIColor.darkColor()
        UITextField.appearance().font = UIFont(name: UIFont.primaryFont(), size: 16.0)
        UITextField.appearance().textColor = UIColor.darkColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                allPossibleIngredients = managedContext().objects(IngredientBase.self)!
            } else {
                let predicate = NSPredicate(format: "name CONTAINS[cd] \"\(newestIngredient)\"")
                allPossibleIngredients = managedContext().objects(IngredientBase.self, predicate: predicate)!
            }
            if allPossibleIngredients.filter({!contains(self.activeIngredients, $0)}).count != possibleIngredients.count {
                possibleIngredients = allPossibleIngredients.filter({!contains(self.activeIngredients, $0)})
            }
        } else {
            recipes = allRecipes.filter(filterRecipes)
        }
        
        if (currentlyTypingIngredient() && possibleIngredients.isEmpty) {
            let emptyStateLabel = UILabel(frame: tableView.frame)
            emptyStateLabel.text = "Sorry -- we don't know what \(searchTerms.last!) is!"
            
            // Style it up here.
            emptyStateLabel.textAlignment = NSTextAlignment.Center
            emptyStateLabel.textColor = UIColor.lighterColor()
            emptyStateLabel.numberOfLines = 3
            emptyStateLabel.font = UIFont(name: UIFont.primaryFont(), size: 24)
            tableView.backgroundView = emptyStateLabel
        } else if (recipes.isEmpty) {
            let emptyStateLabel = UILabel(frame: tableView.frame)
            emptyStateLabel.text = "Sorry -- no recipes with these ingredients."
            
            // Style it up here.
            emptyStateLabel.textAlignment = NSTextAlignment.Center
            emptyStateLabel.textColor = UIColor.lighterColor()
            emptyStateLabel.numberOfLines = 3
            emptyStateLabel.font = UIFont(name: UIFont.primaryFont(), size: 24)
            tableView.backgroundView = emptyStateLabel
        } else {
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
            
            let labelPrefix = join("", activeIngredients.map({ $0.name + " + " }))
            cell.textLabel?.text = "\(labelPrefix)\(ingredient.name)"
            
            let designator = recipesForPossibleIngredients[indexPath.row] > 1 ? "recipes" : "recipe"
            cell.detailTextLabel?.text = "\(recipesForPossibleIngredients[indexPath.row]) \(designator)"
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
        let labelPrefix = join("", activeIngredients.map({ $0.name + " + " }))
        searchBar.text = "\(labelPrefix)\(ingredient.name)"
        searchBar(searchBar, textDidChange: searchBar.text)
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        return !currentlyTypingIngredient()
    }
}