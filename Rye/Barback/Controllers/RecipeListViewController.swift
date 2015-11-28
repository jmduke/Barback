import Foundation
import UIKit

public class RecipeListViewController: UITableViewController, UISearchResultsUpdating {

    var viewTitle: String = ""
    lazy public var recipes: [Recipe] = Recipe.all()
    
    public var searchController: UISearchController?

    override public func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        title = viewTitle
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        styleController()
        self.tableView.delegate = self
    }

    override func styleController() {
        super.styleController()

        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundView = nil
        tableView.backgroundColor = Color.Background.toUIColor()

        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
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
        tableView.reloadData()
    }

    func filterContentForSearchText(searchText: String) {
        recipes = RecipeSearcher().searchAndArrange(searchText)
        setMostRecentSearch(searchText)
        setMostRecentSearchTimestamp()
    }
    
    var searchView: UIView?

    func attachSearchBar() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController!.searchResultsUpdater = self
        self.searchController!.searchBar.scopeButtonTitles = []
        self.searchController!.dimsBackgroundDuringPresentation = false
        self.searchController!.hidesNavigationBarDuringPresentation = false
        self.searchController!.searchBar.styleSearchBar()
        
        let rect = self.searchController!.searchBar.frame
        searchView = UIView(frame: rect)
        searchView!.addSubview(self.searchController!.searchBar)
        self.view.addSubview(searchView!)
        self.searchController!.searchBar.sizeToFit()
        self.tableView.contentInset = UIEdgeInsetsMake(45, 0, 0, 0)
    }
    
    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (searchView == nil) {
            return
        }
        var rect = searchView!.frame
        rect.origin.y = tableView.contentOffset.y + 64 - tableView.frame.origin.y
        searchView!.frame = rect
    }

}