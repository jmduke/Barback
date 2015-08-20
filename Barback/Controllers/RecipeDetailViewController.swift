import WSCoachMarksView
import RealmSwift
import Social
import UIKit

public class RecipeDetailViewController: UIViewController, UIScrollViewDelegate, HasCoachMarks, Shareable, CoachMarksViewDelegate {

    @IBOutlet weak var recipeDiagramViewWidth: NSLayoutConstraint!
    @IBOutlet weak var recipeDiagramViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    var recipe: Recipe?

    var isRandom: Bool?

    @IBOutlet weak var recipeDiagramView: RecipeDiagramView!
    @IBOutlet public weak var directionsTextView: DescriptionTextView!
    @IBOutlet public var nameLabel: RecipeHeaderLabel!
    @IBOutlet public weak var subheadLabel: RecipeSubheadLabel!
    @IBOutlet public weak var informationLabel: RecipeInformationTextView!
    @IBOutlet public var ingredientsTableView : IngredientTableView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var favoriteButton : UIButton!
    @IBOutlet var ingredientsTableViewHeight : NSLayoutConstraint!
    @IBOutlet var similarDrinksTableView: SimilarRecipeTableView!
    @IBOutlet var similarDrinksTableViewHeight: NSLayoutConstraint!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        registerSettingsDefaults()
        return true
    }
    
    func shareableContent() -> [AnyObject] {
        // Handle the printing setup.
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "BarbackRecipe"
        printInfo.outputType = UIPrintInfoOutputType.General
        let formatter = UIMarkupTextPrintFormatter(markupText: recipe!.htmlString)
        formatter.contentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72) // 1" margins
        
        let activities = [printInfo, formatter, "Just made a \(recipe!.name) with @getbarback!", recipe!.url]
        return activities
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if (recipe == nil) {
            recipe = Recipe.random()
            isRandom = true
            
            let randomButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "findNewRecipe")
            self.navigationItem.leftBarButtonItem = randomButton
        }

        recipe!.isNew = false

        nameLabel.recipe = recipe!
        subheadLabel.recipe = recipe!
        informationLabel.recipe = recipe!
        ingredientsTableView.recipe = recipe
        similarDrinksTableView.recipe = recipe
        recipeDiagramView?.recipe = recipe!
        
        ingredientsTableView.selectionAction = {
            (path: NSIndexPath) -> Void in
            self.performSegueWithIdentifier(R.segue.ingredientDetail, sender: self)
        }
        similarDrinksTableView.selectionAction = {
            (path: NSIndexPath) -> Void in
            self.performSegueWithIdentifier(R.segue.similarRecipe, sender: self)
        }
        
        title = recipe!.name

        // Switch tab bar item title back to the title if necessary.
        if (isRandom != nil) {
            navigationController?.tabBarItem.title = "Random"
        }

        favoriteButton.selected = favoritedRecipes.contains(recipe!)
        favoriteButton.addTarget(self, action: "markRecipeAsFavorite", forControlEvents: UIControlEvents.TouchUpInside)



        directionsTextView.text = recipe!.directions

        
        scrollView.delegate = self

        // Allow folks to swipe right to go back.
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "goToPreviousView:")
        rightSwipeRecognizer.numberOfTouchesRequired = 1
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipeRecognizer)
        view.layoutIfNeeded()

        makeContentShareable()
        styleController()
        
    }

    func goToPreviousView(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?)  {
        if (motion == UIEventSubtype.MotionShake && isRandom != nil) {
            findNewRecipe()
        }
    }

    func findNewRecipe() {
        recipe = Recipe.random()
        performSegueWithIdentifier(R.segue.similarRecipe, sender: nil)
    }

    func markRecipeAsFavorite() {
        do {
            let realm = try Realm()
            realm.write {
                self.recipe!.isFavorited = !self.recipe!.isFavorited
                realm.add(self.recipe!)
            }
        } catch { }
        
        if !favoriteButton.selected {
            favoritedRecipes.append(recipe!)
        } else {
            favoritedRecipes.removeAtIndex(favoritedRecipes.indexOf(recipe!)!)
        }
        
        favoriteButton.selected = !favoriteButton.selected
    }
    
    func coachMarksForController() -> [CoachMark] {
        var coachMarks = [CoachMark]()
        
        if (isRandom != nil) {
            // We want the entire thing to hide, so define a 0,0 rect.
            let shakePosition = CGRect(x: 0, y: 0, width: 0, height: 0)
            let shakeCaption = "Don't like this one?  Shake the phone or press the button in the top left corner for a new recipe."
            
            let coachMark = CoachMark(rect: shakePosition, caption: shakeCaption)
            coachMarks.append(coachMark)
        }
        
        coachMarks.append(CoachMark(rect: subheadLabel.frame, caption: "Here are some details about your recipe."))
        coachMarks.append(CoachMark(rect: recipeDiagramView.frame, caption: "This is what it looks like."))
        
        let ingredientsPosition = ingredientsTableView.frame
        let ingredientsCaption = "Here's what's in it.  (Tap an ingredient to learn more about it.)"
        coachMarks.append(CoachMark(rect: ingredientsPosition, caption: ingredientsCaption))
        
        let directionsPosition = directionsTextView.frame
        let directionsCaption = "Here's how you make it."
        coachMarks.append(CoachMark(rect: directionsPosition, caption: directionsCaption))

        let infoPosition = informationLabel.frame
        let infoCaption = "Here's some information about it."
        coachMarks.append(CoachMark(rect: infoPosition, caption: infoCaption))
        
        let favoritePosition = favoriteButton.frame
        let favoriteCaption = "This lil button saves your favorite recipes and lets you easily access them later."
        coachMarks.append(CoachMark(rect: favoritePosition, caption: favoriteCaption))
        
        let similarPosition = similarDrinksTableView.frame
        let similarCaption = "Here are some similar drinks, if you wanna try out something else."
        coachMarks.append(CoachMark(rect: similarPosition, caption: similarCaption))
        
        
        return coachMarks
    }

    override public func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        runCoachMarks(scrollView)
    }

    override public func viewDidLayoutSubviews()  {
        let correctIngredientsHeight = min(view.bounds.size.height, ingredientsTableView.contentSize.height)
        ingredientsTableViewHeight.constant = correctIngredientsHeight

        if ((similarDrinksTableView) != nil) {
            let correctSimilarDrinksHeight = min(view.bounds.size.height, similarDrinksTableView.contentSize.height)
            similarDrinksTableViewHeight.constant = correctSimilarDrinksHeight
        }
        
        recipeDiagramViewHeight.constant = recipeDiagramView!.idealHeight()
        recipeDiagramViewWidth.constant = recipeDiagramView!.idealWidth()
        
        view.layoutIfNeeded()
    }

    override func styleController() {
        super.styleController()

        view.backgroundColor = Color.Background.toUIColor()
        directionsTextView.textColor = Color.Dark.toUIColor()

        view.layoutIfNeeded()
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(R.segue.similarRecipe, sender: nil)
    }

    // Named kinda clumsily because of an ObjC conflict.
    public func setRecipeAs(recipe: Recipe?) {
        self.recipe = recipe

        // Disallow shake gestures.
        resignFirstResponder()
    }

    override public func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue!.identifier == R.segue.ingredientDetail {
            let destination = segue!.destinationViewController as! IngredientDetailViewController
            let ingredient = getSelectedIngredient()
            destination.ingredient = ingredient
        } else {
            let destinationController = getRecipeDetailController(segue)
            let recipe = getSelectedRecipe()
            destinationController.setRecipeAs(recipe)
        }
    }

    func getSelectedIngredient() -> IngredientBase {
        let selectedRow = ingredientsTableView.indexPathForSelectedRow
        let rowIndex = selectedRow?.row
        return recipe!.ingredients[rowIndex!].base!
    }

    func getSelectedRecipe() -> Recipe? {
        let selectedRow = similarDrinksTableView.indexPathForSelectedRow
        if selectedRow != nil {
            let rowIndex = selectedRow?.row
            return recipe!.similarRecipes(2)[rowIndex!]
        } else {
            return nil
        }
    }
    
    func coachMarksViewWillNavigateToIndex(view: CoachMarksView, index: Int) {
        let coachMark = view.coachMarks[index].rect
        scrollView.setContentOffset(CGPoint(x: 0, y: coachMark.origin.y - 50), animated: true)
    }

}
