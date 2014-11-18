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

    func currentlyTypingIngredient() -> Bool {
        let typingIncompleteIngredient = IngredientBase.forName(searchTerms.last ?? "N/A") == nil
        return typingIncompleteIngredient || searchBarFocused
    }
    
    override var viewTitle: String {
        get {
            return "Search"
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
    
    override func styleController() {
        super.styleController()
        
        searchBar.translucent = false
        searchBar.barTintColor = UIColor.darkColor()
        UITextField.appearance().font = UIFont(name: UIFont.primaryFont(), size: 16.0)
        UITextField.appearance().textColor = UIColor.darkColor()
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
        
        let searchBarCaption = "Type stuff in here to search for ingredients (\"vermouth\", \"orange,vodka\"), recipe names (\"punch\")."
        
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
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            let labelPrefix = join("", activeIngredients.map({ $0.name + " + " }))
            
            cell.stylePrimary()
            
            let rangeOfFoundText = (ingredient.name.lowercaseString as NSString).rangeOfString(searchTerms.last!)
            
            let attributes = [NSForegroundColorAttributeName: rangeOfFoundText.length == 0 ? UIColor.lightColor() : UIColor.lighterColor()]
            let boldAttributes = [NSForegroundColorAttributeName: UIColor.lightColor()]
            let attributedText = NSMutableAttributedString(string: "\(labelPrefix)\(ingredient.name)", attributes: attributes)
            attributedText.setAttributes(boldAttributes, range: rangeOfFoundText)
            cell.textLabel?.attributedText = attributedText
            
            let designator = recipesForPossibleIngredients[indexPath.row] > 1 ? "recipes" : "recipe"
            cell.detailTextLabel?.text = "\(recipesForPossibleIngredients[indexPath.row]) \(designator)"
            cell.detailTextLabel?.textColor = UIColor.lighterColor()
            
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
        searchBarFocused = false
        searchBar(searchBar, textDidChange: searchBar.text)
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return !currentlyTypingIngredient()
    }
}