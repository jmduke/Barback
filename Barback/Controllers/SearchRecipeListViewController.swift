//
//  SearchRecipeListViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SearchRecipeListViewController: RecipeListViewController {

    var activeIngredients: [IngredientBase] = [IngredientBase]()
    var possibleIngredients: [IngredientBase] {
        let uses: [List<Ingredient>] = recipes.map({ $0.ingredients })
        let bases = uses.map({ $0.map({ $0.base! }) })
        var uniqueBases = [IngredientBase]()
        for baseList in bases {
            baseList.filter({ !uniqueBases.contains($0) }).map({ uniqueBases.append($0) })
        }
        return uniqueBases.filter({ !activeIngredients.contains($0) }).sort({ $0.name < $1.name })
    }
    var recipeCountsForPossibleIngredients: [Int] {
        let uses: [List<Ingredient>] = recipes.map({ $0.ingredients })
        let bases = uses.map({ $0.map({ $0.base! }) })
        var uniqueBases = [String:Int]()
        for baseList in bases {
            for base in baseList.filter({ !activeIngredients.contains($0) }) {
                uniqueBases[base.name] = (uniqueBases[base.name] ?? 0) + 1
            }
        }
        return uniqueBases.keys.sort({ $0 < $1 }).map({ uniqueBases[$0]! })
    }

    var viewingRecipes: Bool = false

    override var viewTitle: String {
        get {
            if activeIngredients.isEmpty {
                return "Ingredients"
            }
            return ", ".join(activeIngredients.map({ $0.name }))
        }
        set {
            
        }
    }

    func showRecipes() {
        let storyboard = R.storyboard.main.instance
        let destination: SearchRecipeListViewController = storyboard.instantiateViewControllerWithIdentifier("SearchRecipeListViewController") as! SearchRecipeListViewController
        destination.activeIngredients = activeIngredients
        destination.recipes = recipes
        destination.viewingRecipes = true
        self.navigationController?.pushViewController(destination, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        recipes = Recipe.all().filter(filterRecipes)
        
        print(recipes.count)
        
        if possibleIngredients.isEmpty || recipes.count == 1 {
            viewingRecipes = true
        }

        if !activeIngredients.isEmpty && !viewingRecipes {
            let browseRecipesView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 120))
            let browseRecipesButton = SimpleButton(frame: CGRectMake(self.tableView.frame.size.width / 4, 0, self.tableView.frame.size.width / 2, 120))
            browseRecipesButton.titleLabel!.numberOfLines = 0
            browseRecipesButton.titleLabel!.textAlignment = NSTextAlignment.Center
            let recipeList = ", ".join(activeIngredients.map({ $0.name }))
            let title = "See \(recipes.count) recipes with \(recipeList)"
            browseRecipesButton.setTitle(title, forState: UIControlState.Normal)
            browseRecipesButton.setTitleColor(Color.Tint.toUIColor(), forState: UIControlState.Normal)
            browseRecipesButton.addTarget(self, action: "showRecipes", forControlEvents: UIControlEvents.TouchUpInside)
            browseRecipesView.addSubview(browseRecipesButton)
            tableView.tableHeaderView = browseRecipesView
        }

        if viewingRecipes && recipes.count > 1 {
            let bartendersChoiceView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 60))
            let bartendersChoiceButton = SimpleButton(frame: CGRectMake(self.tableView.frame.size.width / 4, 10, self.tableView.frame.size.width / 2, 40))
            bartendersChoiceButton.setTitle("Pick random recipe", forState: UIControlState.Normal)
            bartendersChoiceButton.setTitleColor(Color.Tint.toUIColor(), forState: UIControlState.Normal)
            bartendersChoiceButton.addTarget(self, action: "pickRandomRecipe", forControlEvents: UIControlEvents.TouchUpInside)
            bartendersChoiceView.addSubview(bartendersChoiceButton)
            tableView.tableFooterView = bartendersChoiceView
        }
    }

    func pickRandomRecipe() {
        let randomIndex = Int(arc4random_uniform(UInt32(self.recipes.count))) % self.recipes.count
        self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: randomIndex, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: randomIndex, inSection: 0))
    }

    override func filterRecipes(recipe: Recipe) -> Bool {
        return activeIngredients.filter({ recipe.usesIngredient($0) }).count == activeIngredients.count
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if (viewingRecipes) {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }

        return possibleIngredients.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (viewingRecipes) {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
            return
        }

        let selectedRow = tableView.indexPathForSelectedRow
        let rowIndex = selectedRow?.row
        let ingredient =  possibleIngredients[rowIndex!]

        let storyboard = R.storyboard.main.instance
        let destination: SearchRecipeListViewController = storyboard.instantiateViewControllerWithIdentifier("SearchRecipeListViewController") as! SearchRecipeListViewController
        destination.activeIngredients = activeIngredients
        destination.activeIngredients.append(ingredient)
        self.navigationController?.pushViewController(destination, animated: true)

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (viewingRecipes) {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
            
        let ingredient = possibleIngredients[indexPath.row]
        let cellIdentifier = "recipeCell"
        let cell = BaseCell(base: ingredient, reuseIdentifier: cellIdentifier)

        cell.textLabel?.text = activeIngredients.isEmpty ? ingredient.name : "and \(ingredient.name)"

        let recipeCount = recipeCountsForPossibleIngredients[indexPath.row]
        let designator = recipeCount > 1 ? "recipes" : "recipe"
        cell.detailTextLabel?.text = "\(recipeCount) \(designator)"

        return cell
    }
}