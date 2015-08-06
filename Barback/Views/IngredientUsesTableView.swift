import UIKit
import Foundation

class IngredientUsesTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var ingredient: IngredientBase?  {
        didSet {
            dataSource = self
            delegate = self
            
            self.setNeedsDisplay()
            self.reloadData()
            
            separatorStyle = UITableViewCellSeparatorStyle.None
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = DescriptionLabel(frame: CGRect(x: 0, y: 0, width: 320, height: 60))
        label.text = "Drinks containing \(ingredient!.name)"
        label.styleLabel()
        return label
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredient!.uses().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let cellIdentifier = "drinkCell"
        let recipe = ingredient!.uses()[indexPath.row].recipe!
        cell = RecipeCell(recipe: recipe, reuseIdentifier: cellIdentifier)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.window!.rootViewController! as! UITabBarController
        let navController = controller.viewControllers?.first as! UINavigationController
        navController.visibleViewController!.performSegueWithIdentifier(R.segue.recipeDetail, sender: nil)
        deselectRowAtIndexPath(indexPath, animated: true)
    }
}