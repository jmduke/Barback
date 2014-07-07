//
//  ShoppingListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/19/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import UIKit

class ShoppingListViewController: RecipeListViewController {

    var ingredients: IngredientBase[] = IngredientBase[]()
    let ingredientTypes = ["spirit", "liqueur", "garnish", "mixer", "other"]
    var selectedCellIndices = Int[]()
    
    override var viewTitle: String {
        get {
            return "Shopping List"
        }
    }
    
    init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func setIngredients(ingredients: IngredientBase[]) {
        self.ingredients = ingredients
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create ourselves a back button.
        let backButton = UIBarButtonItem(title: "Back", style:UIBarButtonItemStyle.Bordered, target: self, action: "goBack")
        backButton.setTitleTextAttributes([UITextAttributeFont: UIFont(name: UIFont().primaryFont(), size: 16)], forState: UIControlState.Normal)
        navigationItem.leftBarButtonItem = backButton
        
        // Preserve selection of table elements.
        clearsSelectionOnViewWillAppear = false
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
        let ingredientsForType = ingredients.filter({$0.type == ingredientType})
        return ingredientsForType.count
    }
    
    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        var sectionLabel = UILabel()
        sectionLabel.frame = CGRectMake(20, 0, 320, 40)
        sectionLabel.font = UIFont(name: UIFont().heavyFont(), size: 16)
        sectionLabel.textAlignment = NSTextAlignment.Left
        sectionLabel.textColor = UIColor().lightColor()
        
        sectionLabel.text = ingredientTypes[section].capitalizedString + "s"
        
        var headerView = UIView()
        headerView.addSubview(sectionLabel)
        
        return headerView
    }
    
    
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 40
    }

    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        return ingredientTypes[section]
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        
        let cellIdentifier = "shoppingCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if !cell {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        }
        
        let ingredientType = ingredientTypes[indexPath.section]
        let ingredientsForType = ingredients.filter({$0.type == ingredientType})
        cell!.textLabel.text = ingredientsForType[indexPath.row].name
        cell!.stylePrimary()
        
        
        let cellKey = indexPath.section * 100 + indexPath.row
        if find(selectedCellIndices, cellKey) {
            cell!.textLabel.textColor = UIColor().lighterColor()
        }
        
        return cell!
    }

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        let cellKey = indexPath.section * 100 + indexPath.row
        if let cellIndex = find(selectedCellIndices, cellKey) {
            selectedCell.textLabel.textColor = UIColor().lightColor()
            selectedCellIndices.removeAtIndex(cellIndex)
        } else {
            selectedCell.textLabel.textColor = UIColor().lighterColor()
            selectedCellIndices.append(cellKey)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
