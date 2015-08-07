import UIKit
import Foundation

public class IngredientUsesTableView: RealmObjectTableView {
    
    var ingredient: IngredientBase?  {
        didSet {
            self.initialize()
        }
    }
    
    override func textForHeaderInSection() -> String {
        return "Drinks containing \(ingredient!.name)"
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredient!.uses().count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let cellIdentifier = "drinkCell"
        let recipe = ingredient!.uses()[indexPath.row].recipe!
        cell = RecipeCell(recipe: recipe, reuseIdentifier: cellIdentifier)
        return cell!
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.window!.rootViewController! as! UITabBarController
        let navController = controller.viewControllers?.first as! UINavigationController
        navController.visibleViewController!.performSegueWithIdentifier(R.segue.recipeDetail, sender: nil)
        deselectRowAtIndexPath(indexPath, animated: true)
    }
}