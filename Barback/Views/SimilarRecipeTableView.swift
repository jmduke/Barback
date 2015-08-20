import Foundation
import UIKit

public class SimilarRecipeTableView: RealmObjectTableView {
    
    public var recipe: Recipe?  {
        didSet {
            self.initialize()
        }
    }
    
    override func textForHeaderInSection() -> String {
        return "You may also be interested in"
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe!.similarRecipes(2).count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let cellIdentifier = "similarCell"
        let similarRecipe = recipe!.similarRecipes(2)[indexPath.row]
        cell = RecipeCell(recipe: similarRecipe, reuseIdentifier: cellIdentifier)
        return cell!
    }
}