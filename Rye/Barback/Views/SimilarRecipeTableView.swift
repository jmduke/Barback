import Foundation
import UIKit

public class SimilarRecipeTableView: RealmObjectTableView {
    
    public var recipe: Recipe?  {
        didSet {
            similarRecipes = recipe!.similarRecipes()
            self.initialize()
        }
    }
    
    var similarRecipes: [Recipe]?
    
    override func textForHeaderInSection() -> String {
        return "You may also be interested in"
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(3, similarRecipes?.count ?? 0)
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let cellIdentifier = "similarCell"
        let similarRecipe = similarRecipes![indexPath.row]
        cell = RecipeCell(recipe: similarRecipe, reuseIdentifier: cellIdentifier)
        return cell!
    }
}