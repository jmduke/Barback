import Foundation
import UIKit

class IngredientTableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    var recipe: Recipe?  {
        didSet {
            dataSource = self
            delegate = self
            self.setNeedsDisplay()
            self.reloadData()
            
            separatorStyle = UITableViewCellSeparatorStyle.None
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe!.ingredients.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ingredientCell"
        let ingredient: Ingredient = recipe!.ingredients[indexPath.row]
        let cell = IngredientCell(ingredient: ingredient, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = ingredient.base?.name
        cell.detailTextLabel?.text = ingredient.detailDescription
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.window!.rootViewController! as! UITabBarController
        let navController = controller.viewControllers?.first as! UINavigationController
        navController.visibleViewController!.performSegueWithIdentifier(R.segue.ingredientDetail, sender: nil)
        deselectRowAtIndexPath(indexPath, animated: true)
    }
}