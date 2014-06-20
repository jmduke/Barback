//
//  RecipeListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    var primaryFOnt: String {
    get {
        return "Futura-Medium"
    }
    }
}

class RecipeListViewController: UITableViewController {
    
    let viewTitle: String = ""
    let allRecipes: Recipe[] = Recipe.allRecipes()
    var recipes: Recipe[] = Recipe[]()
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        self.title = viewTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleController()
        self.recipes = self.allRecipes.filter(filterRecipes)
    }
    
    func styleController() {
        self.navigationController.navigationBar.translucent = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor().backgroundColor()
        
        self.navigationController.navigationBar.barTintColor = UIColor().darkColor()
        self.navigationController.navigationBar.topItem.title = viewTitle
        self.navigationController.navigationBar.titleTextAttributes = [UITextAttributeTextColor: UIColor.whiteColor(), UITextAttributeFont: UIFont(name: UIFont().primaryFOnt, size: 20)]
        
        self.tableView.sectionIndexBackgroundColor = UIColor().backgroundColor();
        self.tableView.sectionIndexColor = UIColor().darkColor()
        
        if (self.tabBarController) {
            self.tabBarController.tabBar.translucent = false
            self.tabBarController.tabBar.barTintColor = UIColor().darkColor()
            self.tabBarController.tabBar.tintColor = UIColor().tintColor()
        }
        
        self.tableView.sectionIndexBackgroundColor = UIColor.whiteColor()
        self.tableView.sectionIndexColor = UIColor().darkColor()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([UITextAttributeFont: UIFont(name: UIFont().primaryFOnt, size: 16)], forState: UIControlState.Normal)

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
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let recipe = recipes[indexPath.row]
        
        return cellForRecipe(recipe, andIndexPath: indexPath)
    }
    
    func cellForRecipe(recipe: Recipe, andIndexPath: NSIndexPath) -> UITableViewCell! {
        let cellIdentifier = "recipeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: andIndexPath) as UITableViewCell

        cell.text = recipe.name
        
        let ingredients = recipe.ingredients.filter({ingredient in !ingredient.isSpecial}).map({
            (ingredient: Ingredient) -> String in
            return ingredient.base
            })
        cell.detailTextLabel.text = join(", ", ingredients)
        
        styleCell(cell)
        
        return cell
    }
    
    func styleCell(cell: UITableViewCell) {
        cell.textLabel.font = UIFont(name: UIFont().primaryFOnt, size: 20)
        cell.detailTextLabel.font = UIFont(name: UIFont().primaryFOnt, size: 14)
        
        cell.textLabel.textColor = UIColor().lightColor()
        cell.detailTextLabel.textColor = UIColor().lighterColor()
        
        
        if (cell.textLabel.text == "Bartender's Choice" || cell.textLabel.text == "Shopping List") {
            cell.textLabel.textColor = UIColor().tintColor()
        }
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 60
    }
    
    func getSelectedRecipe() -> Recipe {
        return recipes[self.tableView.indexPathForSelectedRow().row]
    }
    
    
    // We have this logic in here so we don't try and segue on Shopping List.
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        let selectedIndex = self.tableView.indexPathForSelectedRow()
        
        if selectedIndex.row >= recipes.count {
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        
        let destination = segue!.destinationViewController as RecipeDetailViewController
        
        var recipe = getSelectedRecipe()
        if (recipe.name == "Bartender's Choice") {
            let randomIndex = Int(rand()) % (recipes.count - 1)
            recipe = recipes[randomIndex]
        }
        destination.setRecipe(recipe)
    }
    
    // Should be overwritten by subclasses to filter all recipes.
    func filterRecipes(recipe: Recipe) -> Bool {
        return true
    }
    
}