//
//  FavoriteRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class FavoriteRecipeListViewController: RecipeListViewController {
    
    override var viewTitle: String {
    get {
        return "Favorites"
    }
        set { }
    }
    
    override func filterRecipes(recipe: Recipe) -> Bool {
        return recipe.favorite
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        
        if recipes.count > 0 {
            // Return an extra row to account for Shopping List.
            return recipes.count + 1
        } else {
            return recipes.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // If it's the last row, return the Shopping List row.
        if indexPath.row == recipes.count {
            let shoppingListRecipe = Recipe.forName("Shopping List")
            var cell = cellForRecipe(shoppingListRecipe!, andIndexPath: indexPath)
            return cell
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func viewDidAppear(animated: Bool) {
        // We manually reload each appearance to account for favorites in other tabs.

        recipes = Recipe.all().filter(filterRecipes)
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        
        loadCoachMarks()
        
        // Load empty state view if necessary.
        if tableView(tableView, numberOfRowsInSection: 1) == 0 {
            
            let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
            emptyStateLabel.text = "When you mark a recipe as a favorite, it'll show up here."
            
            tableView.backgroundView = emptyStateLabel
        } else {
            tableView.backgroundView = nil
        }
        
        super.viewDidAppear(animated)
    }
    
    func loadCoachMarks() {
        if recipes.count < 3 {
            return
        }
        
        let favoritePosition = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).rectByUnion(tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))).rectByUnion(tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)))
        let favoriteCaption = "Your favorite recipes will show up here.  (I added a few of mine to start you off.)"
        
        let shakePosition = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: recipes.count, inSection: 0))
        let shakeCaption = "We can make you a shopping list with all the ingredients you need to make them, too."
        
        let coachMarks = [["rect": NSValue(CGRect: favoritePosition), "caption": favoriteCaption], ["rect": NSValue(CGRect: shakePosition), "caption": shakeCaption]]
        runCoachMarks(coachMarks)
    }
    
    func ingredientsNeeded() -> [IngredientBase] {
        
        // Grab all the ingredient names.
        let allIngredients = recipes.map({
            (recipe: Recipe) -> [IngredientBase] in
            return recipe.ingredients.map({
                (ingredient: Ingredient) -> IngredientBase in
                return IngredientBase.forName(ingredient.base.name)!
                })
            })
        
        // Flatten it into a list.
        var flattenedIngredients = [IngredientBase]()
        for ingredientList in allIngredients {
            for ingredient in ingredientList {
                flattenedIngredients.append(ingredient)
            }
        }
        
        // Remove duplicates.
        var uniqueIngredients = NSSet(array: flattenedIngredients).allObjects as [IngredientBase]
        uniqueIngredients.sort({$0.name < $1.name})
        return uniqueIngredients
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Special logic to render the shopping list.
        if indexPath.row == recipes.count {
            var shoppingListController = ShoppingListViewController(style: UITableViewStyle.Grouped)
            shoppingListController.setIngredients(ingredientsNeeded())
            navigationController?.pushViewController(shoppingListController, animated: true)
        } else {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
    }

}