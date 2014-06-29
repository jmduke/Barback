//
//  FullRecipeListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class FullRecipeListViewController: RecipeListViewController {
    
    var firstCharactersOfRecipes: String[]?
    var filteredRecipesByFirstCharacter: Recipe[][] = Recipe[][]()
    
    override var viewTitle: String {
        get {
            return "Recipes"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstCharacters = recipes.map({
            (recipe: Recipe) -> String in
            return String(Array(recipe.name)[0])
            })
        self.firstCharactersOfRecipes = NSSet(array: firstCharacters).allObjects as? String[]
        
        for firstCharacter in self.firstCharactersOfRecipes! {
            let firstCharacters = recipes.filter({
                (recipe: Recipe) -> Bool in
                return recipe.name.hasPrefix(firstCharacter)
                })
            self.filteredRecipesByFirstCharacter.append(firstCharacters)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return firstCharactersOfRecipes!.count
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        let firstCharacter = self.firstCharactersOfRecipes![section]
        return recipes.filter({
            (recipe: Recipe) -> Bool in
            return recipe.name.hasPrefix(firstCharacter)
            }).count
    }
    
    override func getSelectedRecipe() -> Recipe {
        return filteredRecipesByFirstCharacter[self.tableView.indexPathForSelectedRow().section][self.tableView.indexPathForSelectedRow().row]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView!) -> AnyObject[]! {
        return firstCharactersOfRecipes
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return cellForRecipe(filteredRecipesByFirstCharacter[indexPath.section][indexPath.row], andIndexPath: indexPath)
    }

}