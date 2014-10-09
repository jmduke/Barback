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
    
    var firstCharactersOfRecipes: [String]?
    var filteredRecipesByFirstCharacter: [[CRecipe]] = [[CRecipe]]()
    
    override var viewTitle: String {
        get {
            return "Recipes"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapRecipesToCharacters()
    }
    
    // Map recipes to their first characters to allow searching with the UITableViewIndex.
    func mapRecipesToCharacters() {
        let firstCharacters = recipes.map({
            (recipe: CRecipe) -> String in
            return String(Array(recipe.name)[0])
            })
        firstCharactersOfRecipes = NSSet(array: firstCharacters).allObjects as? [String]
        
        for firstCharacter in firstCharactersOfRecipes! {
            let firstCharacters = recipes.filter({
                (recipe: CRecipe) -> Bool in
                return recipe.name.hasPrefix(firstCharacter)
                })
            filteredRecipesByFirstCharacter.append(firstCharacters)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return firstCharactersOfRecipes!.count
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        let firstCharacter = firstCharactersOfRecipes![section]
        return recipes.filter({
            (recipe: CRecipe) -> Bool in
            return recipe.name.hasPrefix(firstCharacter)
            }).count
    }
    
    override func getSelectedRecipe() -> CRecipe {
        let selectedRow = tableView.indexPathForSelectedRow()
        let section = selectedRow?.section
        let row = selectedRow?.row
        return filteredRecipesByFirstCharacter[section!][row!]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return firstCharactersOfRecipes
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellForRecipe(filteredRecipesByFirstCharacter[indexPath.section][indexPath.row], andIndexPath: indexPath)
    }

}