//
//  FavoriteRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit
import Parse

class FavoriteRecipeListViewController: RecipeListViewController {
    
    override var viewTitle: String {
    get {
        return "Favorites"
    }
        set { }
    }
    
    override func filterRecipes(recipe: Recipe) -> Bool {
        return contains(favoritedRecipes, recipe)
    }
    
    override func viewDidAppear(animated: Bool) {
        // We manually reload each appearance to account for favorites in other tabs.

        recipes = Recipe.all().filter(filterRecipes).sorted({ $0.name < $1.name })
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        
        // Load empty state view if necessary.
        if tableView(tableView, numberOfRowsInSection: 1) == 0 {
            
            let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
            emptyStateLabel.text = "When you mark a recipe as a favorite, it'll show up here."
            
            tableView.backgroundView = emptyStateLabel
        } else {
            tableView.backgroundView = nil
        }
        
        if (!recipes.isEmpty) {
            var shoppingListView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 60))
            var shoppingListButton = SimpleButton(frame: CGRectMake(self.tableView.frame.size.width / 4, 10, self.tableView.frame.size.width / 2, 40))
            shoppingListButton.setTitle("Shopping List", forState: UIControlState.Normal)
            shoppingListButton.setTitleColor(Color.Tint.toUIColor(), forState: UIControlState.Normal)
            shoppingListButton.addTarget(self, action: "showShoppingList", forControlEvents: UIControlEvents.TouchUpInside)
            shoppingListView.addSubview(shoppingListButton)
            tableView.tableFooterView = shoppingListView
        }
        
        loadCoachMarks()
        
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() == nil {
            let controller: AppLoginViewController = storyboard?.instantiateViewControllerWithIdentifier("loginViewController")! as! AppLoginViewController
            navigationController?.pushViewController(controller, animated: true)
            
        }
    }
    
    func loadCoachMarks() {
        if recipes.count < 3 {
            return
        }
        
        let favoritePosition = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).rectByUnion(tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))).rectByUnion(tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)))
        let favoriteCaption = "Your favorite recipes will show up here.  (I added a few of mine to start you off.)"
        
        let shoppingListPosition = tableView.tableFooterView!.frame
        let shoppingListCaption = "We can make you a shopping list with all the ingredients you need to make them, too."
        
        let coachMarks = [CoachMark(rect: favoritePosition, caption: favoriteCaption), CoachMark(rect: shoppingListPosition, caption: shoppingListCaption)]
        runCoachMarks(coachMarks)
    }
    
    func ingredientsNeeded() -> [IngredientBase] {
        
        // Grab all the ingredient names.
        let allIngredients = recipes.map({
            (recipe: Recipe) -> [IngredientBase] in
            return recipe.ingredients.map({
                (ingredient: Ingredient) -> IngredientBase in
                return ingredient.base
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
        var uniqueIngredients = Array(Set(flattenedIngredients))
        uniqueIngredients.sort({$0.name < $1.name})
        return uniqueIngredients
    }
    
    func showShoppingList() {
        var shoppingListController = ShoppingListViewController(style: UITableViewStyle.Grouped)
        shoppingListController.setIngredientsForController(ingredientsNeeded())
        navigationController?.pushViewController(shoppingListController, animated: true)
    }

}