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
    }
    }
    var isRandom: Bool?
    var similarRecipes: [Recipe]?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var directionsLabel : UILabel!
    @IBOutlet var glasswareLabel : UILabel!
    @IBOutlet var ingredientsTableView : UITableView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var favoriteButton : UIButton!
    @IBOutlet var ingredientsTableViewHeight : NSLayoutConstraint!
    @IBOutlet var facebookButton : UIButton!
    @IBOutlet var similarDrinksTableView: UITableView!
    @IBOutlet var similarDrinksLabel: UILabel!
    @IBOutlet var similarDrinksTableViewHeight: NSLayoutConstraint!
    @IBOutlet var twitterButton : UIButton!

    
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
        
        if !(recipe != nil) {
            recipe = Recipe.random()
            isRandom = true
        }
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        
        similarDrinksTableView.delegate = self
        similarDrinksTableView.dataSource = self
        similarDrinksTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "similarCell")
        
        title = recipe!.name
        
        // Switch tab bar item title back to the title if necessary.
        if( isRandom != nil) {
            navigationController?.tabBarItem.title = "Random"
        }
        
        nameLabel.text = recipe!.name
        directionsLabel.text = recipe!.directions
        glasswareLabel.text = "Serve in \(recipe!.glassware) glass."
        
        facebookButton.addTarget(self, action: "shareOnFacebook", forControlEvents: UIControlEvents.TouchUpInside)
        twitterButton.addTarget(self, action: "shareOnTwitter", forControlEvents: UIControlEvents.TouchUpInside)
        favoriteButton.addTarget(self, action: "markRecipeAsFavorite", forControlEvents: UIControlEvents.TouchUpInside)
        
        scrollView.delegate = self
        
        favoriteButton.selected = recipe!.favorited
        
        
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
            recipe = Recipe.random()
            viewDidLoad()
            viewWillAppear(true)
        }
    }
    
    func shareOnFacebook() {
        let facebookController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        
        facebookController.setInitialText("Just made a \(recipe!.name) with Barback!")
        facebookController.addURL(NSURL(fileURLWithPath: "http://getbarback.com"))
        
        presentViewController(facebookController, animated: true, completion: nil)
    }
    
    func shareOnTwitter() {
        let twitterController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        twitterController.setInitialText("Just made a \(recipe!.name) with @getbarback!")
        twitterController.addURL(NSURL(fileURLWithPath: "http://getbarback.com"))
        
        presentViewController(twitterController, animated: true, completion: nil)
    }
    
    func markRecipeAsFavorite() {
        recipe!.favorited = !recipe!.favorited
        favoriteButton.selected = !favoriteButton.selected
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
        
        view.layoutIfNeeded()
    }
    
    func loadCoachMarks() {
        var coachMarks = [NSDictionary]()
        
        if (isRandom != nil) {
            // We want the entire thing to hide, so define a 0,0 rect.
            let shakePosition = CGRect(x: 0, y: 0, width: 0, height: 0)
            let shakeCaption = "Don't like this one?  Shake the phone for a new recipe."
            
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
            
            let ingredient: Ingredient = recipe!.ingredients[indexPath.row]
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
        return recipe!.ingredients[rowIndex!].base
    }
    
    func getSelectedRecipe() -> Recipe {
        let selectedRow = similarDrinksTableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        return similarRecipes![rowIndex!]
    }
    
}
