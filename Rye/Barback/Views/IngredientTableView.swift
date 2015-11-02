import Foundation
import UIKit

public class IngredientTableView: RealmObjectTableView {
    
    var recipe: Recipe? {
        didSet {
            self.initialize()
        }
    }

    override func textForHeaderInSection() -> String {
        return "Ingredients"
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe!.ingredients.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ingredientCell"
        let ingredient: Ingredient = recipe!.ingredients[indexPath.row]
        let cell = IngredientCell(ingredient: ingredient, reuseIdentifier: cellIdentifier)
        return cell
    }
}