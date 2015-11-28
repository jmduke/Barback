//
//  FullRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import Popover
import UIKit

public class FullRecipeListViewController: RecipeListViewController, UISearchBarDelegate, HasCoachMarks, UINavigationControllerDelegate {

    override public var recipes : [Recipe] {
        didSet {
            if (searchController != nil && searchController!.searchBar.text!.isEmpty) {
                super.recipes = recipes.sort(sortingMethod.sortFunction())
            }
        }
    }

    override var viewTitle: String {
        get {
            return "Recipes"
        }
        set {
        }
    }
    
    let popover = Popover()

    var sortingMethod: RecipeSortingMethod = RecipeSortingMethod.NameDescending
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        recipes = Recipe.all()
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }

    public func toggleSortingMethod() {
        let startPoint = CGPoint(x: 60, y: 55)
        let buttonHeight = CGFloat(60)
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: buttonHeight * 3))

        for (i, method) in sortingMethod.possibleMethods().enumerate() {
            let button = SimpleButton(frame: CGRect(x: 0, y: CGFloat(i) * buttonHeight, width: self.view.frame.width / 2, height: buttonHeight))
            button.setTitle(method.title(), forState: UIControlState.Normal)
            button.setTitleColor(Color.Tint.toUIColor(), forState: UIControlState.Normal)
            button.tag = method.rawValue
            button.addTarget(self, action: "changeSortingMethod:", forControlEvents: UIControlEvents.TouchUpInside)
            aView.addSubview(button)
            
        }

        popover.show(aView, point: startPoint)
    }
    
    public override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let sectionTitles = RecipeArranger().getSectionTitles(sortingMethod, recipes: recipes)
        
        // Don't show the section titles if there's only one because it looks dumb.
        if sectionTitles.count < 2 {
            return nil
        }
        
        // Don't show the section titles if there isn't enough recipes to scrub.
        if recipes.count < 6 {
            return nil
        }
        
        return sectionTitles
    }
    
    public override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return RecipeArranger().getSectionTitles(sortingMethod, recipes: recipes).indexOf(title)!
    }
    
    public override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if !(searchController!.searchBar.text!.isEmpty) {
            return recipes.count
        }
        return RecipeArranger().getSectionSize(sortingMethod, recipes: recipes, sectionIndex: section)
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        if !(searchController!.searchBar.text!.isEmpty) {
            return 1
        }
        return RecipeArranger().getSectionCount(sortingMethod, recipes: recipes)
    }
    
    public func changeSortingMethod(sender: UIButton) {
        sortingMethod = RecipeSortingMethod(rawValue: sender.tag)!
        recipes = recipes.sort(sortingMethod.sortFunction())
        tableView.reloadData()
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        self.navigationItem.leftBarButtonItem!.title = sortingMethod.title()
        popover.dismiss()
    }
    
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.definesPresentationContext = true
        self.navigationController?.delegate = self
        
        attachSearchBar()

        let sortButton = UIBarButtonItem(title: sortingMethod.title(), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSortingMethod")
        self.navigationItem.leftBarButtonItem = sortButton

        runCoachMarks(view)
    }
    
    func getRecipe(indexPath: NSIndexPath) -> Recipe {
        if !(searchController!.searchBar.text!.isEmpty) {
            return recipes[indexPath.row]
        }
        return RecipeArranger().getRecipesInSection(sortingMethod, recipes: recipes,sectionIndex: indexPath.section)[indexPath.row]
    }

    override func getSelectedRecipe() -> Recipe {
        return getRecipe(tableView.indexPathForSelectedRow!)
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recipe = getRecipe(indexPath)
        let cell = cellForRecipe(recipe, andIndexPath: indexPath) as! RecipeCell
        if (searchController!.active) {
            cell.highlightText(searchController!.searchBar.text!)
        }
        return cell
    }
    
    func coachMarksForController() -> [CoachMark] {
        return [
            CoachMark(rect: tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)), caption: "Recipes.  (The good stuff.)"),
            CoachMark(rect: (self.searchController?.searchBar.frame)!, caption: "Search recipes by name or description.")
        ]
    }

}