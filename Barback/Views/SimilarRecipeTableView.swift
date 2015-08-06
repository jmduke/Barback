import Foundation
import UIKit

class SimilarRecipeTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var recipe: Recipe?  {
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
        label.text = "You may also be interested in:"
        label.styleLabel()
        return label
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe!.similarRecipes(2).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let cellIdentifier = "similarCell"
        let similarRecipe = recipe!.similarRecipes(2)[indexPath.row]
        cell = RecipeCell(recipe: similarRecipe, reuseIdentifier: cellIdentifier)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.window!.rootViewController! as! UITabBarController
        let navController = controller.viewControllers?.first as! UINavigationController
        navController.visibleViewController!.performSegueWithIdentifier(R.segue.similarRecipe, sender: nil)
        deselectRowAtIndexPath(indexPath, animated: true)
    }
}