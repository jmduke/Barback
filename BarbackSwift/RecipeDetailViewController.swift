//
//  RecipeDetailViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/14/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Social
import UIKit

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var recipe: Recipe? {
    willSet {
        similarRecipes = newValue!.similarRecipes(2)
        
        let ingredients = newValue!.ingredients
        sortedIngredients = ingredients.sorted({$0.amount?.intValue > $1.amount?.intValue})
    }
    }
    
    var isRandom: Bool?
    var similarRecipes: [Recipe]?
    var sortedIngredients: [Ingredient]?
    
    @IBOutlet weak var informationLabelHeight: NSLayoutConstraint!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var subheadLabel: UILabel!
    @IBOutlet var directionsLabel : UILabel!
    @IBOutlet var informationLabel : UILabel!
    @IBOutlet var ingredientsTableView : UITableView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var favoriteButton : UIButton!
    @IBOutlet var ingredientsTableViewHeight : NSLayoutConstraint!
    @IBOutlet var similarDrinksTableView: UITableView!
    @IBOutlet var similarDrinksLabel: UILabel!
    @IBOutlet var similarDrinksTableViewHeight: NSLayoutConstraint!
    
    let externalUrl = NSURL(scheme: "http", host: "getbarback.com", path: "/")

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if (!userDefaults.boolForKey("useImperialUnits")) {
            let appDefaults = ["useImperialUnits": true]
            userDefaults.registerDefaults(appDefaults)
            userDefaults.synchronize()
        }
        
        return true
    }
    
    func shareRecipe() {
        let activities = ["Just made a \(recipe!.name) with @getbarback!", externalUrl!]
        let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let randomButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareRecipe")
        self.navigationItem.rightBarButtonItem = randomButton
        
        if (recipe == nil) {
            recipe = getRandomRecipe()
            isRandom = true
            
            let randomButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "findNewRecipe")
            self.navigationItem.leftBarButtonItem = randomButton
        }
        
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        
        similarDrinksTableView.delegate = self
        similarDrinksTableView.dataSource = self
        similarDrinksTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "similarCell")
        
        title = recipe!.name
        
        // Switch tab bar item title back to the title if necessary.
        if (isRandom != nil) {
            navigationController?.tabBarItem.title = "Random"
        }
        
        favoriteButton.selected = recipe!.favorite
        favoriteButton.addTarget(self, action: "markRecipeAsFavorite", forControlEvents: UIControlEvents.TouchUpInside)
        
        nameLabel.text = recipe!.name
        directionsLabel.text = recipe!.directions
        subheadLabel.text = "\(Int(recipe!.abv))% ABV · Served in \(recipe!.glassware) glass"
        informationLabel.text = recipe!.information ?? ""
        
        
        scrollView.delegate = self
        
        // Allow folks to swipe right to go back.
        var rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "goToPreviousView:")
        rightSwipeRecognizer.numberOfTouchesRequired = 1
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipeRecognizer)
        
        // Most recipes don't have descriptions at this point.
        let labelShouldBeHidden = informationLabel.text == ""
        informationLabel.hidden = labelShouldBeHidden
        informationLabelHeight.constant = labelShouldBeHidden ? 0 : 21
        
        // If there aren't any similar recipes, we can just hide the relevant elements.
        let similarRecipesExist = similarRecipes!.count > 0
        similarDrinksLabel.hidden = !similarRecipesExist
        similarDrinksTableView.hidden = !similarRecipesExist
        view.layoutIfNeeded()
        
        styleController()
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
        recipe = getRandomRecipe()
        viewWillAppear(true)
        viewDidLoad()
    }
    
    func getRandomRecipe() -> Recipe {
        var randomRecipe = Recipe.random()
        while (!randomRecipe.isReal || (recipe != nil && randomRecipe == recipe!)) {
            randomRecipe = Recipe.random()
        }
        return randomRecipe
    }
    
    func markRecipeAsFavorite() {
        
        // Make the recipe's heart grow three sizes.
        UIView.animateWithDuration(0.1, delay: 0.0, options:UIViewAnimationOptions.CurveEaseIn, animations: {
            self.favoriteButton.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }, completion: {
                (success: Bool) in
                UIView.animateWithDuration(0.1, delay: 0.0, options:UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.favoriteButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: nil)
        })
        
        recipe!.isFavorited = !recipe!.favorite
        favoriteButton.selected = !favoriteButton.selected
        saveContext()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ingredientsTableView.reloadData()
        similarDrinksTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        

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
        
        scrollView.backgroundColor = UIColor.backgroundColor()
        
        nameLabel.textColor = UIColor.darkColor()
        nameLabel.font = UIFont(name: UIFont.heavyFont(), size: 32)
        nameLabel.textAlignment = NSTextAlignment.Center
        
        subheadLabel.font = UIFont(name: UIFont.heavyFont(), size: 15)
        subheadLabel.textAlignment = NSTextAlignment.Center
        subheadLabel.textColor = UIColor.lightColor()
        
        directionsLabel.font = UIFont(name: UIFont.primaryFont(), size: 15)
        directionsLabel.textAlignment = NSTextAlignment.Center
        directionsLabel.textColor = UIColor.darkColor()
        
        informationLabel.font = UIFont(name: UIFont.heavyFont(), size: 15)
        informationLabel.textAlignment = NSTextAlignment.Center
        informationLabel.textColor = UIColor.lightColor()
        
        similarDrinksLabel.font = UIFont(name: UIFont.heavyFont(), size: 15)
        similarDrinksLabel.textAlignment = NSTextAlignment.Center
        similarDrinksLabel.textColor = UIColor.lightColor()
        
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
        
        let directionsPosition = directionsLabel.frame
        let directionsCaption = "Simple instructions on making your drinks."
        coachMarks.append(["rect": NSValue(CGRect: directionsPosition), "caption": directionsCaption])
        
        let ingredientsPosition = ingredientsTableView.frame
        let ingredientsCaption = "Tap an ingredient to learn more about it."
        coachMarks.append(["rect": NSValue(CGRect: ingredientsPosition), "caption": ingredientsCaption])
        
        runCoachMarks(coachMarks)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        
        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
            
            var favoritePosition = favoriteButton.frame
            favoritePosition.offset(dx: 0, dy: -scrollOffset)
            let favoriteCaption = "This button saves your favorite recipes and lets you easily access them later."
            let scrolledCoachMarks = [["rect": NSValue(CGRect: favoritePosition), "caption": favoriteCaption]]
            runCoachMarks(scrolledCoachMarks)
            
        }
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
            cell = StyledCell(style: UITableViewCellStyle.Value1,
                    reuseIdentifier: cellIdentifier)
            
            let ingredient: Ingredient = sortedIngredients![indexPath.row]
            cell!.textLabel?.text = ingredient.base.name
            cell!.detailTextLabel?.text = ingredient.detailDescription
        } else {
            let cellIdentifier = "similarCell"
            let recipe = similarRecipes![indexPath.row]
            cell = RecipeCell(recipe: recipe, reuseIdentifier: cellIdentifier)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if tableView == ingredientsTableView {
            performSegueWithIdentifier("ingredientDetail", sender: nil)
        } else {
            performSegueWithIdentifier("similarRecipe", sender: nil)
        }
    }
    
    func setRecipe(recipe: Recipe) {
        self.recipe = recipe
        
        // Disallow shake gestures.
        resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue!.identifier == "ingredientDetail" {
            let destination = segue!.destinationViewController as IngredientDetailViewController
            var ingredient = getSelectedIngredient()
            destination.setIngredient(ingredient)
        } else {
            let destination = segue!.destinationViewController as RecipeDetailViewController
            var recipe = getSelectedRecipe()
            destination.setRecipe(recipe)
        }
    }
    
    func getSelectedIngredient() -> IngredientBase {
        let selectedRow = ingredientsTableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        
        let ingredient = sortedIngredients![rowIndex!]
        return IngredientBase.forName(ingredient.base.name)!
    }
    
    func getSelectedRecipe() -> Recipe {
        let selectedRow = similarDrinksTableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        return similarRecipes![rowIndex!]
    }
    
}
