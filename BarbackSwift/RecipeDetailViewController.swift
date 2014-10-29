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
        
        let ingredients = newValue!.ingredients.allObjects as [Ingredient]
        sortedIngredients = ingredients.sorted({$0.amount?.intValue > $1.amount?.intValue})
    }
    }
    
    var isRandom: Bool?
    var similarRecipes: [Recipe]?
    var sortedIngredients: [Ingredient]?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var directionsLabel : UILabel!
    @IBOutlet var glasswareLabel : UILabel!
    @IBOutlet var ingredientsTableView : UITableView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var favoriteButton : RecipeDetailActionButton!
    @IBOutlet var ingredientsTableViewHeight : NSLayoutConstraint!
    @IBOutlet var facebookButton : RecipeDetailActionButton!
    @IBOutlet var similarDrinksTableView: UITableView!
    @IBOutlet var similarDrinksLabel: UILabel!
    @IBOutlet var similarDrinksTableViewHeight: NSLayoutConstraint!
    @IBOutlet var twitterButton : RecipeDetailActionButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (recipe == nil) {
            recipe = getRandomRecipe()
            isRandom = true
            
            let randomButton = UIBarButtonItem(title: "New Recipe", style: UIBarButtonItemStyle.Plain, target: self, action: "findNewRecipe")
            self.navigationItem.rightBarButtonItem = randomButton
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
        
        favoriteButton.selectedAlpha = 1.0
        favoriteButton.selected = recipe!.isFavorited
        
        nameLabel.text = recipe!.name
        directionsLabel.text = recipe!.directions
        glasswareLabel.text = "Serve in \(recipe!.glassware) glass."
        
        facebookButton.setAction(self, action: "shareOnFacebook")
        twitterButton.setAction(self, action: "shareOnTwitter")
        favoriteButton.setAction(self, action: "markRecipeAsFavorite")
        
        scrollView.delegate = self
        
        // Allow folks to swipe right to go back.
        var rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "goToPreviousView:")
        rightSwipeRecognizer.numberOfTouchesRequired = 1
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipeRecognizer)
        
        // If there aren't any similar recipes, we can just hide the relevant elements.
        if similarRecipes!.count == 0 {
            similarDrinksLabel.removeFromSuperview()
            similarDrinksTableView.removeFromSuperview()
            view.layoutIfNeeded()
        }
        
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
        var randomRecipe = managedContext().randomObject(Recipe.self)!
        while (!randomRecipe.isReal) {
            randomRecipe = managedContext().randomObject(Recipe.self)!
        }
        return randomRecipe
    }
    
    func shareOnFacebook() {
        facebookButton.selected = true
        
        let facebookController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        
        facebookController.setInitialText("Just made a \(recipe!.name) with Barback!")
        facebookController.addURL(externalUrl)
        facebookController.completionHandler = {(SLComposeViewControllerResult result) -> Void in
            self.facebookButton.selected = false
        }
        
        presentViewController(facebookController, animated: true, completion: nil)
    }
    
    func shareOnTwitter() {
        twitterButton.selected = true
        let twitterController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        twitterController.setInitialText("Just made a \(recipe!.name) with @getbarback!")
        twitterController.addURL(externalUrl)
        twitterController.completionHandler = {(SLComposeViewControllerResult result) -> Void in
            self.twitterButton.selected = false
        }
        
        presentViewController(twitterController, animated: true, completion: nil)
    }
    
    func markRecipeAsFavorite() {
        recipe!.isFavorited = !recipe!.isFavorited
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
        
        directionsLabel.font = UIFont(name: UIFont.primaryFont(), size: 15)
        directionsLabel.textAlignment = NSTextAlignment.Center
        directionsLabel.textColor = UIColor.darkColor()
        
        glasswareLabel.font = UIFont(name: UIFont.heavyFont(), size: 15)
        glasswareLabel.textAlignment = NSTextAlignment.Center
        glasswareLabel.textColor = UIColor.lightColor()
        
        similarDrinksLabel.font = UIFont(name: UIFont.heavyFont(), size: 15)
        similarDrinksLabel.textAlignment = NSTextAlignment.Center
        similarDrinksLabel.textColor = UIColor.lightColor()
    
        // Don't change the opacity of favorite button even when it's selected.
        favoriteButton.selectedAlpha = 1
        
        view.layoutIfNeeded()
    }
    
    func loadCoachMarks() {
        var coachMarks = [NSDictionary]()
        
        if (isRandom != nil) {
            // We want the entire thing to hide, so define a 0,0 rect.
            let shakePosition = CGRect(x: 0, y: 0, width: 0, height: 0)
            let shakeCaption = "Don't like this one?  Shake the phone or press the \"New Recipe\" button for a new recipe."
            
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
            cell = UITableViewCell(style: UITableViewCellStyle.Value1,
                    reuseIdentifier: cellIdentifier)
            
            let ingredient: Ingredient = sortedIngredients![indexPath.row]
            cell!.textLabel?.text = ingredient.base.name
            cell!.detailTextLabel?.text = ingredient.detailDescription
        } else {
            let cellIdentifier = "similarCell"
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: cellIdentifier)
            
            let similarRecipe = similarRecipes![indexPath.row]
            cell!.textLabel?.text = similarRecipe.name
            cell!.detailTextLabel?.text = similarRecipe.detailDescription
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
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        cell.stylePrimary()
    }
    
    
    func getSelectedIngredient() -> IngredientBase {
        let selectedRow = ingredientsTableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        
        let ingredient = sortedIngredients![rowIndex!]
        return managedContext().objectForName(IngredientBase.self, name: ingredient.base.name)!
    }
    
    func getSelectedRecipe() -> Recipe {
        let selectedRow = similarDrinksTableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        return similarRecipes![rowIndex!]
    }
    
}
