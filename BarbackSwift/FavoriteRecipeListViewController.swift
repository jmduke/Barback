//
//  FavoriteRecipeListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class FavoriteRecipeListViewController: RecipeListViewController {
    
    override var viewTitle: String {
    get {
        return "Favorites"
    }
    }
    
    override func filterRecipes(recipe: Recipe) -> Bool {
        return recipe.favorited
    }
    
    override func viewDidAppear(animated: Bool) {
        // We manually reload each appearance to account for favorites in other tabs.
        self.viewDidLoad()
        self.tableView.reloadData()
    }

}