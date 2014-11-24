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
    var filteredRecipesByFirstCharacter: [[Recipe]] = [[Recipe]]()
    
    override var viewTitle: String {
        get {
            return "Recipes"
        }
        set {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapRecipesToCharacters()
        
        let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
        emptyStateLabel.text = "Sorry, we can't get you recipes until you connect to the internet!"
        tableView.backgroundView = emptyStateLabel
        
        let reachability = Reachability.reachabilityForInternetConnection()
        reachability.reachableBlock = {
            (r: Reachability!) -> Void in
            let _ = Async.main {
                let hud = MBProgressHUD(view: self.view)
                self.view.addSubview(hud)
                hud.labelText = "Fetching you some great recipes."
                hud.show(true)
            }.background {
                while (!NSUserDefaults.standardUserDefaults().boolForKey("syncedThisLaunch")) {
                    continue
                }}.main {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.recipes = Recipe.all()
                    self.mapRecipesToCharacters()
                    self.tableView.reloadData()
                }
        }
        reachability.startNotifier()
    }
    
    // Map recipes to their first characters to allow searching with the UITableViewIndex.
    func mapRecipesToCharacters() {
        let firstCharacters = recipes.map({
            (recipe: Recipe) -> String in
            return String(Array(recipe.name)[0])
        })
        firstCharactersOfRecipes = (NSSet(array: firstCharacters).allObjects as? [String])!.sorted({$0 < $1})
        
        for firstCharacter in firstCharactersOfRecipes! {
            let firstCharacters = recipes.filter({
                (recipe: Recipe) -> Bool in
                return recipe.name.hasPrefix(firstCharacter)
            }).sorted({ $0.name < $1.name })
            filteredRecipesByFirstCharacter.append(firstCharacters)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return firstCharactersOfRecipes!.count
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        let firstCharacter = firstCharactersOfRecipes![section]
        return recipes.filter({
            (recipe: Recipe) -> Bool in
            return recipe.name.hasPrefix(firstCharacter)
            }).count
    }
    
    override func getSelectedRecipe() -> Recipe {
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