//
//  RecipeDetailViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/14/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Parse
import Social
import UIKit

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var recipe: Recipe? {
    willSet {
        similarRecipes = newValue?.similarRecipes(2)
        
        let ingredients = newValue?.ingredients
        sortedIngredients = ingredients?.sorted({$0.amount.intValue > $1.amount.intValue})
    }
    }
    
    @IBOutlet weak var recipeDiagramWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var recipeDiagramHeightConstraint: NSLayoutConstraint!
    var isRandom: Bool?
    var similarRecipes: [Recipe]?
    var sortedIngredients: [Ingredient]?
    
    @IBOutlet weak var recipeDiagramView: RecipeDiagramView!
    @IBOutlet weak var directionsTextView: DescriptionTextView!
    @IBOutlet var nameLabel: HeaderLabel!
    @IBOutlet weak var subheadLabel: UILabel!
    @IBOutlet weak var informationLabel: DescriptionTextView!
    @IBOutlet var ingredientsTableView : UITableView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var favoriteButton : UIButton!
    @IBOutlet var ingredientsTableViewHeight : NSLayoutConstraint!
    @IBOutlet var similarDrinksTableView: UITableView!
    @IBOutlet var similarDrinksLabel: UILabel!
    @IBOutlet var similarDrinksTableViewHeight: NSLayoutConstraint!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        registerSettingsDefaults()
        return true
    }
    
    func shareRecipe() {
        
        // Handle the printing setup.
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "BarbackRecipe"
        printInfo.outputType = UIPrintInfoOutputType.General
        let formatter = UIMarkupTextPrintFormatter(markupText: recipe!.htmlString)
        formatter.contentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72) // 1" margins

        let activities = [printInfo, formatter, "Just made a \(recipe!.name) with @getbarback!", recipe!.url]
        let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        navigationController?.presentViewController(controller, animated: true, completion: nil)
        
        // Needed to play nice with iPad views.
        if (controller.respondsToSelector("popoverPresentationController")) {
            let presentationController = controller.popoverPresentationController
            let shareButton = self.navigationItem.rightBarButtonItem
            presentationController?.barButtonItem = shareButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareRecipe")
        self.navigationItem.rightBarButtonItem = shareButton
        
        if (recipe == nil) {
            recipe = Recipe.random()
            isRandom = true
            
            let randomButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "findNewRecipe")
            self.navigationItem.leftBarButtonItem = randomButton
        }
        
        recipe!.isNew = false
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        
        similarDrinksTableView.delegate = self
        similarDrinksTableView.dataSource = self
        similarDrinksTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "similarCell")
        
        title = recipe!.name
        recipeDiagramView?.recipe = recipe!
        recipeDiagramView?.drawRect(recipeDiagramView!.frame)
        recipeDiagramHeightConstraint.constant = recipeDiagramView!.idealHeight()
        recipeDiagramWidthConstraint.constant = recipeDiagramView!.idealWidth()
        
        // Switch tab bar item title back to the title if necessary.
        if (isRandom != nil) {
            navigationController?.tabBarItem.title = "Random"
        }
        
        favoriteButton.selected = contains(favoritedRecipes, recipe!)
        favoriteButton.addTarget(self, action: "markRecipeAsFavorite", forControlEvents: UIControlEvents.TouchUpInside)
        
        nameLabel.text = recipe!.name
        directionsTextView.text = recipe!.directions
        subheadLabel.text = "\(Int(recipe!.abv))% ABV · Served in \(recipe!.glassware) glass"
        
        if (recipe!.garnish != nil && recipe!.garnish != "") {
            subheadLabel.text = subheadLabel.text! + " · Garnish with \(recipe!.garnish!.lowercaseString) "
        }
        
        informationLabel.markdownText = recipe!.information ?? ""
        informationLabel.sizeToFit()
        informationLabel.layoutIfNeeded()
        
        scrollView.delegate = self
        
        // Allow folks to swipe right to go back.
        var rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "goToPreviousView:")
        rightSwipeRecognizer.numberOfTouchesRequired = 1
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipeRecognizer)
        
        // Most recipes don't have descriptions at this point.
        let labelShouldBeHidden = informationLabel.text == ""
        informationLabel.hidden = labelShouldBeHidden
        
        // If there aren't any similar recipes, we can just hide the relevant elements.
        let similarRecipesExist = similarRecipes!.count > 0
        similarDrinksLabel.hidden = !similarRecipesExist
        similarDrinksTableView.hidden = !similarRecipesExist
        recipeDiagramView.setNeedsDisplay()
        recipeDiagramView.layoutIfNeeded()
        view.layoutIfNeeded()
        
        styleController()
        nameLabel.styleLabel()
    }
    
    func goToPreviousView(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent)  {
        if (motion == UIEventSubtype.MotionShake && isRandom != nil) {
            findNewRecipe()
        }
    }
    
    func findNewRecipe() {
        recipe = Recipe.random()
        performSegueWithIdentifier("similarRecipe", sender: nil)
    }
    
    func actuallyFavoriteRecipe() {
        var favorite = Favorite()
        favorite.user = PFUser.currentUser()!
        favorite.recipe = recipe!
        favorite.saveInBackground()
        favoritedRecipes.append(recipe!)
        
        // Make the recipe's heart grow three sizes.
        UIView.animateWithDuration(0.1, delay: 0.0, options:UIViewAnimationOptions.CurveEaseIn, animations: {
            self.favoriteButton.transform = CGAffineTransformMakeScale(1.5, 1.5)
            }, completion: {
                (success: Bool) in
                UIView.animateWithDuration(0.1, delay: 0.0, options:UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.favoriteButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }, completion: nil)
        })
        
        favoriteButton.selected = !favoriteButton.selected
    }
    
    func markRecipeAsFavorite() {
        
        if PFUser.currentUser() == nil {
            PFTwitterUtils.logInWithBlock({
                (user, error) in
                    if let user = user {
                        self.actuallyFavoriteRecipe()
                    }
                })
        } else if !favoriteButton.selected {
            actuallyFavoriteRecipe()
        } else {
            favoriteButton.selected = !favoriteButton.selected
            favoritedRecipes.removeAtIndex(find(favoritedRecipes, recipe!)!)
            Favorite.deleteSilently(PFUser.currentUser()!, recipe: recipe!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ingredientsTableView.reloadData()
        similarDrinksTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        
        // Note that this will not grab random recipes.
        PFAnalytics.trackEventInBackground("recipeOpened", dimensions: ["recipe": recipe!.name], block: nil)
        
        loadCoachMarks()
    }
    
    override func viewDidLayoutSubviews()  {
        let correctIngredientsHeight = min(view.bounds.size.height, ingredientsTableView.contentSize.height)
        ingredientsTableViewHeight.constant = correctIngredientsHeight
        
        if ((similarDrinksTableView) != nil) {
            let correctSimilarDrinksHeight = min(view.bounds.size.height, similarDrinksTableView.contentSize.height)
            similarDrinksTableViewHeight.constant = correctSimilarDrinksHeight
            view.layoutIfNeeded()
        }
    }
    
    override func styleController() {
        super.styleController()
        
        directionsTextView.textColor = Color.Dark.toUIColor()
        
        view.layoutIfNeeded()
    }
    
    func loadCoachMarks() {
        var coachMarks = [NSDictionary]()
        
        if (isRandom != nil) {
            // We want the entire thing to hide, so define a 0,0 rect.
            let shakePosition = CGRect(x: 0, y: 0, width: 0, height: 0)
            let shakeCaption = "Don't like this one?  Shake the phone or press the button in the top left corner for a new recipe."
            
            let coachMark = ["rect": NSValue(CGRect: shakePosition), "caption": shakeCaption]
            coachMarks.append(coachMark)
        }
        
        let directionsPosition = directionsTextView.frame
        let directionsCaption = "Simple instructions on making your drinks."
        coachMarks.append(["rect": NSValue(CGRect: directionsPosition), "caption": directionsCaption])
        
        let ingredientsPosition = ingredientsTableView.frame
        let ingredientsCaption = "Tap an ingredient to learn more about it."
        coachMarks.append(["rect": NSValue(CGRect: ingredientsPosition), "caption": ingredientsCaption])
        
        var favoritePosition = favoriteButton.frame
        let favoriteCaption = "This button saves your favorite recipes and lets you easily access them later."
        coachMarks.append(["rect": NSValue(CGRect: favoritePosition), "caption": favoriteCaption])
        
        runCoachMarks(coachMarks)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == ingredientsTableView) {
            return recipe!.ingredients.count
        } else {
            return similarRecipes!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if (tableView == ingredientsTableView) {
            let cellIdentifier = "ingredientCell"
            
            let ingredient: Ingredient = sortedIngredients![indexPath.row]
            cell = IngredientCell(ingredient: ingredient, reuseIdentifier: cellIdentifier)
            cell!.textLabel?.text = ingredient.base.name
            cell!.detailTextLabel?.text = ingredient.detailDescription
        } else {
            let cellIdentifier = "similarCell"
            let recipe = similarRecipes![indexPath.row]
            cell = RecipeCell(recipe: recipe, reuseIdentifier: cellIdentifier)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == ingredientsTableView {
            performSegueWithIdentifier("ingredientDetail", sender: nil)
        } else {
            performSegueWithIdentifier("similarRecipe", sender: nil)
        }
    }
    
    func setRecipeForController(recipe: Recipe?) {
        self.recipe = recipe

        // Disallow shake gestures.
        resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue!.identifier == "ingredientDetail" {
            let destination = segue!.destinationViewController as! IngredientDetailViewController
            var ingredient = getSelectedIngredient()
            destination.setIngredientForController(ingredient)
        } else {
            var destinationController = getRecipeDetailController(segue)
            var recipe = getSelectedRecipe()
            destinationController.setRecipeForController(recipe)
        }
    }
    
    func getSelectedIngredient() -> IngredientBase {
        let selectedRow = ingredientsTableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        return sortedIngredients![rowIndex!].base
    }
    
    func getSelectedRecipe() -> Recipe? {
        let selectedRow = similarDrinksTableView.indexPathForSelectedRow()
        if selectedRow != nil {
            let rowIndex = selectedRow?.row
            return similarRecipes![rowIndex!]
        } else {
            return nil
        }
    }
    
}
