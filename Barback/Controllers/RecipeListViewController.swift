import Foundation
import UIKit

public class RecipeListViewController: UITableViewController, UISearchResultsUpdating {

    var viewTitle: String = ""
    lazy public var recipes: [Recipe] = Recipe.all()
    
    public var searchController: UISearchController?

    override public func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        title = viewTitle

        // We reload this to remove isNew identifier after seeing recipe.
        tableView.reloadData()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        styleController()
    }

    override func styleController() {
        super.styleController()

        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundView = nil
        tableView.backgroundColor = Color.Background.toUIColor()

        tableView.sectionIndexBackgroundColor = Color.Background.toUIColor()
        tableView.sectionIndexColor = Color.Dark.toUIColor()

        tableView.sectionIndexBackgroundColor = UIColor.whiteColor()
        tableView.sectionIndexColor = Color.Dark.toUIColor()

        let fontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
            .pointSize, 16)
        UITextField.appearance().font = UIFont(name: UIFont.primaryFont(), size: fontSize)
        UITextField.appearance().textColor = Color.Background.toUIColor()

        navigationItem.titleView?.tintColor = Color.Dark.toUIColor()
        navigationItem.titleView?.backgroundColor = Color.Dark.toUIColor()
    }

    override public func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }

    override public func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recipe = recipes[indexPath.row]

        return cellForRecipe(recipe, andIndexPath: indexPath)
    }

    func cellForRecipe(recipe: Recipe, andIndexPath: NSIndexPath) -> UITableViewCell! {
        let cellIdentifier = "recipeCell"
        let cell = RecipeCell(recipe: recipe, reuseIdentifier: cellIdentifier)

        return cell
    }

    override public func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(StyledCell.cellHeight)
    }

    func getSelectedRecipe() -> Recipe {
        let selectedRow = tableView.indexPathForSelectedRow

        let rowIndex = selectedRow?.row
        return recipes[rowIndex!]
    }


    // We have this logic in here so we don't try and segue on Shopping List.
    override public func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let selectedIndex = tableView.indexPathForSelectedRow

        if selectedIndex?.row >= recipes.count {
            return false
        }
        return true
    }

    override public func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let destinationController = getRecipeDetailController(segue)

        let recipe = getSelectedRecipe()

        destinationController.setRecipeAs(recipe)
        UIApplication.sharedApplication().statusBarHidden = false
    }

    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(R.segue.recipeDetail, sender: nil)
    }


    // Should be overwritten or super-called by subclasses to filter all recipes.
    func filterRecipes(recipe: Recipe) -> Bool {
        return true
    }
    
    public func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchedText = searchController.searchBar.text!
        if (!searchedText.isEmpty) {
            self.filterContentForSearchText(searchedText)
            if (recipes.isEmpty) {
                let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
                emptyStateLabel.text = "Sorry, we couldn't find any recipes matching '\(searchedText)'."
                tableView.backgroundView = emptyStateLabel
            } else {
                tableView.backgroundView = nil
            }
        } else {
            recipes = Recipe.all()
        }
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }

    func filterContentForSearchText(searchText: String) {
        recipes = Recipe.all().filter({
            $0.matchesText(searchText)
        })
        recipes.sortInPlace({
            let firstLocation = $0.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            let secondLocation = $1.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            if (secondLocation?.startIndex == nil) {
                return true
            }
            
            if (firstLocation?.startIndex == nil) {
                return false
            }

            return firstLocation?.startIndex < secondLocation?.startIndex
        })
    }

    func attachSearchBar() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController!.searchResultsUpdater = self
        self.searchController!.searchBar.scopeButtonTitles = []
        self.searchController!.dimsBackgroundDuringPresentation = false
        self.searchController!.hidesNavigationBarDuringPresentation = false
        self.searchController!.searchBar.styleSearchBar()
        self.tableView.tableHeaderView = UIView(frame: self.searchController!.searchBar.frame)
        self.tableView.tableHeaderView!.addSubview(self.searchController!.searchBar)
        self.searchController!.searchBar.sizeToFit()
    }

}