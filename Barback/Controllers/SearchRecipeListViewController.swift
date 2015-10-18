import Foundation
import Popover
import RealmSwift
import UIKit

public class SearchRecipeListViewController: RecipeListViewController, UISearchBarDelegate, HasCoachMarks {

    public var activeIngredients: [IngredientBase] = [IngredientBase]() {
        didSet {
            possibleIngredients = getPossibleIngredients()
            recipeCountsForPossibleIngredients = getRecipeCounts()
        }
    }

    // Use functions instead of evaluated vars for these since they should never change;
    // as soon as we recipes or activeIngredients change, we use a new controller.
    var possibleIngredients: [IngredientBase] = []
    func getPossibleIngredients() -> [IngredientBase] {
        let uses: [List<Ingredient>] = self.recipes.map({ $0.ingredients })
        let bases = uses.map({ $0.map({ $0.base! }) })
        var uniqueBases = [IngredientBase]()
        for baseList in bases {
            baseList.filter({ !uniqueBases.contains($0) }).map({ uniqueBases.append($0) })
        }
        return uniqueBases
                .filter({!self.activeIngredients.contains($0) })
                .sort({ $0.name < $1.name })
                .filter({
                    self.searchController == nil ||
                    self.searchController!.searchBar.text == "" ||
                    $0.name.lowercaseString.rangeOfString(self.searchController!.searchBar.text!.lowercaseString) != nil ||
                    $0.emoji.rangeOfString(self.searchController!.searchBar.text!.lowercaseString) != nil
                })
    }
    
    var recipeCountsForPossibleIngredients: [String:Int] = [:]
    func getRecipeCounts() -> [String:Int] {
        let uses: [List<Ingredient>] = self.recipes.map({ $0.ingredients })
        let bases = uses.map({ $0.map({ $0.base! }) })
        var uniqueBases = [String:Int]()
        for baseList in bases {
            for base in baseList.filter({ !self.activeIngredients.contains($0) }) {
                uniqueBases[base.name] = (uniqueBases[base.name] ?? 0) + 1
            }
        }
        return uniqueBases
    }

    var viewingRecipes: Bool = false

    override var viewTitle: String {
        get {
            if activeIngredients.isEmpty {
                return "Ingredients"
            }
            return activeIngredients.map({ $0.name }).joinWithSeparator(", ")
        }
        set { }
    }
    
    
    let popover = Popover()
    var sortingMethod: IngredientBaseSortingMethod = IngredientBaseSortingMethod.NameDescending
    
    public func toggleSortingMethod() {
        let startPoint = CGPoint(x: 40, y: 55)
        let buttonHeight = CGFloat(60)
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: buttonHeight * 3))
        
        for (i, method) in sortingMethod.possibleMethods().enumerate() {
            let button = SimpleButton(frame: CGRect(x: 0, y: CGFloat(i) * buttonHeight, width: self.view.frame.width / 2, height: buttonHeight))
            button.setTitle(method.title(), forState: UIControlState.Normal)
            button.setTitleColor(Color.Tint.toUIColor(), forState: UIControlState.Normal)
            button.tag = method.rawValue
            button.addTarget(self, action: "changeSortingMethod:", forControlEvents: UIControlEvents.TouchUpInside)
            aView.addSubview(button)
            
        }
        
        popover.show(aView, point: startPoint)
    }
    
    public func changeSortingMethod(sender: UIButton) {
        sortingMethod = IngredientBaseSortingMethod(rawValue: sender.tag)!
        
        possibleIngredients = possibleIngredients.sort(sortingMethod.sortFunction())
        
        // Override # of recipes to include what we know.
        if (sortingMethod == .RecipeUsageAscending) {
            possibleIngredients = possibleIngredients.sort({
                recipeCountsForPossibleIngredients[$0.name] < recipeCountsForPossibleIngredients[$1.name]
            })
        } else if (sortingMethod == .RecipeUsageDescending) {
            possibleIngredients = possibleIngredients.sort({
                recipeCountsForPossibleIngredients[$0.name] > recipeCountsForPossibleIngredients[$1.name]
            })
        }
        
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        self.navigationItem.leftBarButtonItem!.title = sortingMethod.title()
        popover.dismiss()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if !viewingRecipes {
            attachSearchBar()
        }
        let sortButton = UIBarButtonItem(title: sortingMethod.title(), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSortingMethod")
        self.navigationItem.leftBarButtonItem = sortButton
        runCoachMarks(view)
    }

    func showRecipes() {
        let storyboard = R.storyboard.main.instance
        let destination: SearchRecipeListViewController = storyboard.instantiateViewControllerWithIdentifier("SearchRecipeListViewController") as! SearchRecipeListViewController
        destination.activeIngredients = activeIngredients
        destination.recipes = recipes
        destination.viewingRecipes = true
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func showIngredient() {
        let storyboard = R.storyboard.main.instance
        let destination: IngredientDetailViewController = storyboard.instantiateViewControllerWithIdentifier("ingredientDetail") as! IngredientDetailViewController
        destination.ingredient = activeIngredients.first!
        self.navigationController?.pushViewController(destination, animated: true)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        recipes = Recipe.all().filter(filterRecipes)
        possibleIngredients = getPossibleIngredients()
        recipeCountsForPossibleIngredients = getRecipeCounts()
        
        if possibleIngredients.isEmpty || recipes.count == 1 {
            viewingRecipes = true
        }

        if !activeIngredients.isEmpty && !viewingRecipes {
            let browseRecipesViewFrame = CGRectMake(0, 0, self.tableView.frame.size.width, 200)
            let browseRecipesView = BrowseRecipesView(frame: browseRecipesViewFrame)
            browseRecipesView.delegate = self
            browseRecipesView.ingredients = activeIngredients
            tableView.tableHeaderView = browseRecipesView
        }

        if viewingRecipes && recipes.count > 1 {
            let bartendersChoiceView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 60))
            let bartendersChoiceButton = SimpleButton(frame: CGRectMake(50, 10, self.tableView.frame.size.width - 100, 40))
            bartendersChoiceButton.setTitle("Pick random recipe", forState: UIControlState.Normal)
            bartendersChoiceButton.setTitleColor(Color.Tint.toUIColor(), forState: UIControlState.Normal)
            bartendersChoiceButton.addTarget(self, action: "pickRandomRecipe", forControlEvents: UIControlEvents.TouchUpInside)
            bartendersChoiceView.addSubview(bartendersChoiceButton)
            tableView.tableFooterView = bartendersChoiceView
        }
    }

    func pickRandomRecipe() {
        let randomIndex = Int(arc4random_uniform(UInt32(self.recipes.count))) % self.recipes.count
        self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: randomIndex, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: randomIndex, inSection: 0))
    }

    override func filterRecipes(recipe: Recipe) -> Bool {
        return activeIngredients.filter({ recipe.usesIngredient($0) }).count == activeIngredients.count
    }

    override public func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if (viewingRecipes) {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        return possibleIngredients.count
    }

    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        searchController?.dismissViewControllerAnimated(true, completion: nil)
        
        // If you're viewing recipes, just use the superclass.
        if (viewingRecipes) {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
            return
        }
        
        let ingredient =  possibleIngredients[indexPath.row]
        
        // If there's only one possible recipe, go ahead and show it.
        if recipeCountsForPossibleIngredients[ingredient.name] == 1 {
            let recipe = recipes.filter({ $0.usesIngredient(ingredient) }).first
            let destination = R.storyboard.main.recipeDetail!
            destination.recipe = recipe
            self.navigationController?.pushViewController(destination, animated: true)
            return
        }

        // Otherwise, push the thing onto itself.
        let destination = R.storyboard.main.searchRecipeListViewController!
        destination.activeIngredients = activeIngredients + [ingredient]
        self.navigationController?.pushViewController(destination, animated: true)

    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if (viewingRecipes) {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        if (indexPath.row >= possibleIngredients.count) {
            return UITableViewCell(frame: CGRectZero)
        }
            
        let ingredient = possibleIngredients[indexPath.row]
        let cellIdentifier = "recipeCell"
        
        let cell = BaseCell(bases: activeIngredients + [ingredient], reuseIdentifier: cellIdentifier)

        if !activeIngredients.isEmpty {
            cell.textLabel?.text = "and " + cell.textLabel!.text!
        }

        let recipeCount = recipeCountsForPossibleIngredients[ingredient.name] ?? 0
        let designator = recipeCount == 1 ? "recipe" : "recipes"
        cell.detailTextLabel?.text = "\(recipeCount) \(designator)"

        return cell
    }
    
    override func filterContentForSearchText(searchText: String) {
        possibleIngredients = getPossibleIngredients()
    }
    
    override public func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchedText = searchController.searchBar.text!
        self.filterContentForSearchText(searchedText)
        if (possibleIngredients.isEmpty) {
            let emptyStateLabel = EmptyStateLabel(frame: tableView.frame)
            emptyStateLabel.text = "Sorry, we couldn't find any ingredients matching '\(searchedText)'."
            tableView.backgroundView = emptyStateLabel
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func coachMarksForController() -> [CoachMark] {
        return [
            CoachMark(rect: tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)), caption: "Click on ingredients to learn more and find recipes that use them."),
            CoachMark(rect: (self.searchController?.searchBar.frame) ?? CGRectZero, caption: "Search through 'em by name or description.")
        ]
    }

}