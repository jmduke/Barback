//
//  ShoppingListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/19/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import UIKit

class ShoppingListViewController: RecipeListViewController {

    var ingredients: [IngredientBase] = [IngredientBase]() {
    willSet(newIngredients) {
        ingredientTypes = IngredientType.allValues.filter({
            (type: IngredientType) -> Bool in
            return (
                !newIngredients.filter({ IngredientType(rawValue: $0.type) == type }).isEmpty
            )
        })
    }
    }
    
    var ingredientTypes: [IngredientType] = [IngredientType]()
    var favoritedRecipes: [Recipe] = []
    
    override var viewTitle: String {
        get {
            return "Shopping List"
        }
        set {
            
        }
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func setIngredients(ingredients: [IngredientBase]) {
        self.ingredients = ingredients
        favoritedRecipes = Recipe.all().filter({ $0.favorite })
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func goBack() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return ingredientTypes.count
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        let ingredientType = ingredientTypes[section]
        let ingredientsForType = ingredients.filter({IngredientType(rawValue: $0.type) == ingredientType})
        return ingredientsForType.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        var sectionLabel = DescriptionLabel()
        sectionLabel.frame = CGRectMake(20, 0, 320, 40)
        
        sectionLabel.text = ingredientTypes[section].pluralize().capitalizedString
        
        var headerView = UIView()
        headerView.addSubview(sectionLabel)
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return ingredientTypes[section].rawValue
    }
    
    func ingredientForIndexPath(indexPath: NSIndexPath) -> IngredientBase {
        let ingredientType = ingredientTypes[indexPath.section]
        let ingredientsForType = ingredients.filter({IngredientType(rawValue: $0.type) == ingredientType})
        return ingredientsForType[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "shoppingCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if !(cell != nil) {
            cell = StyledCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let ingredient = ingredientForIndexPath(indexPath)
        cell!.textLabel?.text = ingredient.name
        
        let recipeCount = favoritedRecipes.filter({ $0.usesIngredient(ingredient) }).count
        let designator = recipeCount > 1 ? "recipes" : "recipe"
        cell!.detailTextLabel?.text = "Used in \(recipeCount) \(designator)"
        
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("IngredientDetailViewController") as IngredientDetailViewController
        controller.setIngredient(ingredientForIndexPath(indexPath))
        navigationController?.pushViewController(controller, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
