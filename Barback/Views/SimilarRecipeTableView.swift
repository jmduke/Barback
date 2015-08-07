import Foundation
import UIKit

class SimilarRecipeTableView: RealmObjectTableView {
    
    var recipe: Recipe?  {
        didSet {
            self.initialize()
        }
    }
    
    override func textForHeaderInSection() -> String {
        return "You may also be interested in"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe!.similarRecipes(2).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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