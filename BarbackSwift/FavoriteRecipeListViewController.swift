//
//  FavoriteRecipeListViewController.swift
//  BarbackSwift
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
    }
    
    override func filterRecipes(recipe: Recipe) -> Bool {
        return recipe.favorited
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        
        // Return an extra row to account for Shopping List.
        return recipes.count + 1
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        // If it's the last row, return the Shopping List row.
        if indexPath.row == recipes.count {
            let shoppingListRecipe = Recipe(name: "Shopping List")
            var cell = cellForRecipe(shoppingListRecipe, andIndexPath: indexPath)
            return cell
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func viewDidAppear(animated: Bool) {
        // We manually reload each appearance to account for favorites in other tabs.
        self.viewDidLoad()
        self.tableView.reloadData()
    }
    
    func ingredientsNeeded() -> String[] {
        
        // Grab all the ingredient names.
        let allIngredients = recipes.map({
            (recipe: Recipe) -> String[] in
            return recipe.ingredients.map({$0.base.name})
            })
        
        // Flatten it into a list.
        var flattenedIngredients = String[]()
        for ingredientList in allIngredients {
            for ingredient in ingredientList {
                flattenedIngredients.append(ingredient)
            }
        }
        
        // Remove duplicates.
        var uniqueIngredients = NSSet(array: flattenedIngredients).allObjects as String[]
        uniqueIngredients.sort({$0 < $1})
        return uniqueIngredients
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        // Special logic to render the shopping list.
        if indexPath.row == recipes.count {
            var shoppingListController = ShoppingListViewController(style: UITableViewStyle.Grouped)
            shoppingListController.setIngredients(ingredientsNeeded())
            
            var navController = UINavigationController(rootViewController: shoppingListController)
            navController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            
            self.presentModalViewController(navController, animated: true)
        }
    }

}