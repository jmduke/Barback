//
//  RecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import Parse
import UIKit

public class RecipeListViewController: UITableViewController {
    
    var viewTitle: String = ""
    public var recipes: [Recipe] = []
    
    override public func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        title = viewTitle
        
        PFAnalytics.trackEventInBackground("viewControllerOpened", dimensions: ["title": viewTitle], block: nil)
        
        // We reload this to remove isNew identifier after seeing recipe.
        tableView.reloadData()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        styleController()
    }
    
    override func styleController() {
        super.styleController()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundView = nil
        tableView.backgroundColor = Color.Background.toUIColor()
        
        tableView.sectionIndexBackgroundColor = Color.Background.toUIColor()
        tableView.sectionIndexColor = Color.Dark.toUIColor()
        
        tableView.sectionIndexBackgroundColor = UIColor.whiteColor()
        tableView.sectionIndexColor = Color.Dark.toUIColor()
        
        UITextField.appearance().font = UIFont(name: UIFont.primaryFont(), size: 16.0)
        UITextField.appearance().textColor = Color.Background.toUIColor()
        
        navigationItem.titleView?.tintColor = Color.Dark.toUIColor()
        navigationItem.titleView?.backgroundColor = Color.Dark.toUIColor()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override public func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recipe = recipes[indexPath.row]
        
        return cellForRecipe(recipe, andIndexPath: indexPath)
    }
    
    func cellForRecipe(recipe: Recipe, andIndexPath: NSIndexPath) -> UITableViewCell! {
        let cellIdentifier = "recipeCell"
        let cell = RecipeCell(recipe: recipe, reuseIdentifier: cellIdentifier)
        
        return cell
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(StyledCell.cellHeight)
    }
    
    func getSelectedRecipe() -> Recipe {
        let selectedRow = tableView.indexPathForSelectedRow()

        let rowIndex = selectedRow?.row
        return recipes[rowIndex!]
    }
    
    
    // We have this logic in here so we don't try and segue on Shopping List.
    override public func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        let selectedIndex = tableView.indexPathForSelectedRow()
        
        if selectedIndex?.row >= recipes.count {
            return false
        }
        return true
    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        var destinationController = getRecipeDetailController(segue)
        
        var recipe = getSelectedRecipe()
        
        destinationController.setRecipeAs(recipe)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("recipeDetail", sender: nil)
    }
    
    
    // Should be overwritten or super-called by subclasses to filter all recipes.
    func filterRecipes(recipe: Recipe) -> Bool {
        return true
    }
    
}