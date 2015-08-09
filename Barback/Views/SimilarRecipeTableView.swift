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
}