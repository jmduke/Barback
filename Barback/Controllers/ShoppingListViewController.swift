//
//  ShoppingListViewController.swift
//  Barback
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
                !newIngredients.filter({ $0.ingredientType == type }).isEmpty
            )
        })
    }
    }

    var ingredientTypes: [IngredientType] = [IngredientType]()

    override var viewTitle: String {
        get {
            return "Shopping List"
        }
        set {
            
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setIngredientsForController(ingredients: [IngredientBase]) {
        self.ingredients = ingredients
        recipes = Recipe.favorites()
    }

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return ingredientTypes.count
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        let ingredientType = ingredientTypes[section]
        let ingredientsForType = ingredients.filter({ $0.ingredientType == ingredientType})
        return ingredientsForType.count
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let sectionLabel = IngredientTypeSectionLabel()
        sectionLabel.ingredientType = ingredientTypes[section]
        sectionLabel.frame = CGRectMake(0, 0, tableView.frame.width, 40)
        let headerView = UIView()
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
        let ingredientsForType = ingredients.filter({ $0.ingredientType == ingredientType })
        return ingredientsForType[indexPath.row]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellIdentifier = "shoppingCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
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

        let controller = R.storyboard.main.ingredientDetail!
        controller.ingredient = ingredientForIndexPath(indexPath)
        navigationController?.pushViewController(controller, animated: true)

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
