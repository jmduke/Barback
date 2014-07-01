//
//  ShoppingListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/19/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import UIKit

class ShoppingListViewController: RecipeListViewController {

    var ingredients: String[] = String[]()
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
    
    func setIngredients(ingredients: String[]) {
        self.ingredients = ingredients
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create ourselves a back button.
        let backButton = UIBarButtonItem(title: "Back", style:UIBarButtonItemStyle.Bordered, target: self, action: "goBack")
        backButton.setTitleTextAttributes([UITextAttributeFont: UIFont(name: UIFont().primaryFont(), size: 16)], forState: UIControlState.Normal)
        self.navigationItem.leftBarButtonItem = backButton
        
        // Preserve selection of table elements.
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 40
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        
        let cellIdentifier = "shoppingCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if !cell {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel.text = self.ingredients[indexPath.row]
        if find(selectedCellIndices, indexPath.row) {
            cell!.textLabel.textColor = UIColor().lighterColor()
        }
        return cell!
    }

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        if let cellIndex = find(selectedCellIndices, indexPath.row) {
            selectedCell.textLabel.textColor = UIColor().lightColor()
            selectedCellIndices.removeAtIndex(cellIndex)
        } else {
            selectedCell.textLabel.textColor = UIColor().lighterColor()
            selectedCellIndices.append(indexPath.row)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
