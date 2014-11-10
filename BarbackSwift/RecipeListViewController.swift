//
//  RecipeListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class RecipeListViewController: UITableViewController {
    
    var viewTitle: String = ""
    var recipes: [Recipe] = Recipe.all()
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        title = viewTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleController()
        recipes = Recipe.all().filter(filterRecipes)
    }
    
    override func styleController() {
        super.styleController()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.backgroundColor()
        
        tableView.sectionIndexBackgroundColor = UIColor.backgroundColor();
        tableView.sectionIndexColor = UIColor.darkColor()
        
        tableView.sectionIndexBackgroundColor = UIColor.whiteColor()
        tableView.sectionIndexColor = UIColor.darkColor()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recipe = recipes[indexPath.row]
        
        return cellForRecipe(recipe, andIndexPath: indexPath)
    }
    
    func cellForRecipe(recipe: Recipe, andIndexPath: NSIndexPath) -> UITableViewCell! {
        let cellIdentifier = "recipeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: andIndexPath) as UITableViewCell

        cell.textLabel.text = recipe.name
        cell.detailTextLabel?.text = recipe.detailDescription
        cell.stylePrimary()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(UITableViewCell().primaryCellHeight())
    }
    
    func getSelectedRecipe() -> Recipe {
        let selectedRow = tableView.indexPathForSelectedRow()

        let rowIndex = selectedRow?.row
        return recipes[rowIndex!]
    }
    
    
    // We have this logic in here so we don't try and segue on Shopping List.
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        let selectedIndex = tableView.indexPathForSelectedRow()
        
        if selectedIndex?.row >= recipes.count {
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let destination = segue!.destinationViewController as RecipeDetailViewController
        
        var recipe = getSelectedRecipe()
        
        if (recipe.name == "Bartender's Choice") {
            let randomIndex = Int(arc4random_uniform(UInt32(recipes.count))) % (recipes.count - 1)
            recipe = recipes[randomIndex]
        }
        destination.setRecipe(recipe)
    }
    
    // Should be overwritten or super-called by subclasses to filter all recipes.
    func filterRecipes(recipe: Recipe) -> Bool {
        return true
    }
    
}