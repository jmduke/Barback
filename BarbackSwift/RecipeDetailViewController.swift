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

    var recipe: Recipe?
    var isRandom: Bool?
    var similarRecipes: Recipe[]?
    
    @IBOutlet var nameLabel: UILabel
    @IBOutlet var directionsLabel : UILabel
    @IBOutlet var glasswareLabel : UILabel
    @IBOutlet var ingredientsTableView : UITableView
    @IBOutlet var scrollView : UIScrollView
    @IBOutlet var favoriteButton : UIButton
    @IBOutlet var ingredientsTableViewHeight : NSLayoutConstraint
    @IBOutlet var facebookButton : UIButton
    @IBOutlet var similarDrinksTableView: UITableView
    @IBOutlet var similarDrinksLabel: UILabel
    @IBOutlet var similarDrinksTableViewHeight: NSLayoutConstraint
    @IBOutlet var twitterButton : UIButton

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.boolForKey("useImperialUnits") == nil {
            let appDefaults = ["useImperialUnits": true]
            userDefaults.registerDefaults(appDefaults)
            userDefaults.synchronize()
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !recipe {
            recipe = Recipe.random()
            similarRecipes = recipe!.similarRecipes(3)
            self.isRandom = true
        }
        
        // Tell tables to look at this class for info.
        self.ingredientsTableView.delegate = self
        self.ingredientsTableView.dataSource = self
        self.ingredientsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        self.similarDrinksTableView.delegate = self
        self.similarDrinksTableView.dataSource = self
        self.similarDrinksTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "similarCell")
        

        // Set nav bar title.
        self.title = recipe!.name
        
        // Switch tab bar item title back to the title if necessary.
        if self.isRandom {
            self.navigationController.tabBarItem.title = "Random"
        }
        
        // Grab data from recipe.
        nameLabel.text = recipe!.name
        directionsLabel.text = recipe!.directions
        glasswareLabel.text = "Serve in \(recipe!.glassware) glass."
        
        // Register methods for buttons.
        self.facebookButton.addTarget(self, action: "shareOnFacebook", forControlEvents: UIControlEvents.TouchUpInside)
        self.twitterButton.addTarget(self, action: "shareOnTwitter", forControlEvents: UIControlEvents.TouchUpInside)
        self.favoriteButton.addTarget(self, action: "markRecipeAsFavorite", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.scrollView.delegate = self
        
        self.favoriteButton.selected = recipe!.favorited
        
        
        // Allow folks to swipe right to go back.
        var rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "goToPreviousView:")
        rightSwipeRecognizer.numberOfTouchesRequired = 1
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(rightSwipeRecognizer)
        
        if self.similarRecipes!.count == 0 {
            self.similarDrinksLabel.removeFromSuperview()
            self.similarDrinksTableView.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
        
        styleController()
    }
    
    func goToPreviousView(sender: AnyObject) {
        self.navigationController.popToRootViewControllerAnimated(true)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent!)  {
        if motion == UIEventSubtype.MotionShake && self.isRandom {
            self.recipe = Recipe.random()
            self.similarRecipes = self.recipe!.similarRecipes(3)
            self.viewDidLoad()
            self.viewWillAppear(true)
        }
    }
    
    func shareOnFacebook() {
        let facebookController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        
        facebookController.setInitialText("Just made a \(recipe!.name) with Barback!")
        facebookController.addURL(NSURL(fileURLWithPath: "http://getbarback.com"))
        
        self.presentViewController(facebookController, animated: true, completion: nil)
    }
    
    func shareOnTwitter() {
        let twitterController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        twitterController.setInitialText("Just made a \(recipe!.name) with @getbarback!")
        twitterController.addURL(NSURL(fileURLWithPath: "http://getbarback.com"))
        
        self.presentViewController(twitterController, animated: true, completion: nil)
    }
    
    func markRecipeAsFavorite() {
        recipe!.favorited = !recipe!.favorited
        self.favoriteButton.selected = !self.favoriteButton.selected
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.ingredientsTableView.reloadData()
        self.similarDrinksTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        
        loadCoachMarks()
    }
    
    override func viewDidLayoutSubviews()  {
        let correctIngredientsHeight = min(self.view.bounds.size.height, self.ingredientsTableView.contentSize.height)
        self.ingredientsTableViewHeight.constant = correctIngredientsHeight
        
        let correctSimilarDrinksHeight = min(self.view.bounds.size.height, self.similarDrinksTableView.contentSize.height)
        self.similarDrinksTableViewHeight.constant = correctSimilarDrinksHeight
        self.view.layoutIfNeeded()
    }
    
    override func styleController() {
        super.styleController()
        
        self.scrollView.backgroundColor = UIColor().backgroundColor()
        
        self.nameLabel.textColor = UIColor().darkColor()
        self.nameLabel.font = UIFont(name: UIFont().heavyFont(), size: 32)
        self.nameLabel.textAlignment = NSTextAlignment.Center
        
        self.directionsLabel.font = UIFont(name: UIFont().primaryFont(), size: 15)
        self.directionsLabel.textAlignment = NSTextAlignment.Center
        self.directionsLabel.textColor = UIColor().darkColor()
        
        self.glasswareLabel.font = UIFont(name: UIFont().heavyFont(), size: 15)
        self.glasswareLabel.textAlignment = NSTextAlignment.Center
        self.glasswareLabel.textColor = UIColor().lightColor()
        
        self.similarDrinksLabel.font = UIFont(name: UIFont().heavyFont(), size: 15)
        self.similarDrinksLabel.textAlignment = NSTextAlignment.Center
        self.similarDrinksLabel.textColor = UIColor().lightColor()
        
        self.view.layoutIfNeeded()
    }
    
    func loadCoachMarks() {
        var coachMarks = NSDictionary[]()
        
        if self.isRandom {
            // We want the entire thing to hide, so define a 0,0 rect.
            let shakePosition = CGRect(x: 0, y: 0, width: 0, height: 0)
            let shakeCaption = "Don't like this one?  Shake the phone for a new recipe."
            
            let coachMark = ["rect": NSValue(CGRect: shakePosition), "caption": shakeCaption]
            coachMarks.append(coachMark)
        }
        
        let directionsPosition = self.directionsLabel.frame
        let directionsCaption = "Simple instructions on making your drinks."
        coachMarks.append(["rect": NSValue(CGRect: directionsPosition), "caption": directionsCaption])
        
        let ingredientsPosition = self.ingredientsTableView.frame
        let ingredientsCaption = "Tap an ingredient to learn more about it."
        coachMarks.append(["rect": NSValue(CGRect: ingredientsPosition), "caption": ingredientsCaption])
        
        runCoachMarks(coachMarks)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        
        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
            
            var favoritePosition = self.favoriteButton.frame
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
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.ingredientsTableView) {
            return recipe!.ingredients.count
        } else {
            return similarRecipes!.count
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: UITableViewCell?
        if (tableView == self.ingredientsTableView) {
            let cellIdentifier = "ingredientCell"
            cell = UITableViewCell(style: UITableViewCellStyle.Value1,
                    reuseIdentifier: cellIdentifier)
            
            let ingredient: Ingredient = recipe!.ingredients[indexPath.row]
            cell!.textLabel.text = ingredient.base.name
            cell!.detailTextLabel.text = ingredient.detailDescription
        } else {
            let cellIdentifier = "similarCell"
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: cellIdentifier)
            
            let similarRecipe = similarRecipes![indexPath.row]
            cell!.textLabel.text = similarRecipe.name
            cell!.detailTextLabel.text = similarRecipe.detailDescription
        }
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if tableView == self.ingredientsTableView {
            self.performSegueWithIdentifier("ingredientDetail", sender: nil)
        } else {
            self.performSegueWithIdentifier("similarRecipe", sender: nil)
        }
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func setRecipe(recipe: Recipe) {
        self.recipe = recipe
        self.similarRecipes = recipe.similarRecipes(2)
        
        // Disallow shake gestures.
        self.resignFirstResponder()
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
        return self.recipe!.ingredients[self.ingredientsTableView.indexPathForSelectedRow().row].base
    }
    
    func getSelectedRecipe() -> Recipe {
        return self.similarRecipes![self.similarDrinksTableView.indexPathForSelectedRow().row]
    }
    
}
