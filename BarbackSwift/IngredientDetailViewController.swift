//
//  IngredientDetailViewController.swift
//  
//
//  Created by Justin Duke on 6/22/14.
//
//

import UIKit

class IngredientDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var ingredientNameLabel : UILabel
    @IBOutlet var ingredientDescriptionLabel : UILabel
    @IBOutlet var brandTableLabel : UILabel
    @IBOutlet var drinksTableLabel : UILabel
    @IBOutlet var brandsTableView : UITableView
    @IBOutlet var scrollView : UIScrollView
    @IBOutlet var drinksTableView : UITableView
    @IBOutlet var drinkTableViewHeight : NSLayoutConstraint
    @IBOutlet var brandTableViewHeight : NSLayoutConstraint
    
    var ingredient: IngredientBase
    var recipes: Recipe[]
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.ingredient = IngredientBase()
        self.recipes = Recipe[]()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(coder aDecoder: NSCoder!) {
        self.ingredient = IngredientBase()
        self.recipes = Recipe[]()
        super.init(coder: aDecoder)
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.drinksTableView) {
            return recipes.count
        }
        else {
            return ingredient.brands.count
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: UITableViewCell?
        var cellIdentifier: String
        var primaryText: String
        var detailText: String
        
        if (tableView == self.drinksTableView) {
            cellIdentifier = "drinkCell"
            
            let recipe = recipes[indexPath.row]
            primaryText = recipe.name
            detailText = recipe.detailDescription
            
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: cellIdentifier)
        }
        else {
            cellIdentifier = "brandCell"
            
            let brand = ingredient.brands[indexPath.row]
            primaryText = brand.name
            detailText = String(brand.detailDescription)
            
            cell = UITableViewCell(style: UITableViewCellStyle.Value1,
                reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel.text = primaryText
        cell!.detailTextLabel.text = detailText
        
        styleCell(cell!)
        return cell
    }
    
    override func viewDidLayoutSubviews()  {
        
        if self.brandTableViewHeight {
            let correctBrandsHeight = self.brandsTableView.contentSize.height
            self.brandTableViewHeight.constant = correctBrandsHeight
        }
        
        let correctDrinksHeight = self.drinksTableView.contentSize.height
        self.drinkTableViewHeight.constant = correctDrinksHeight
        
        self.view.layoutIfNeeded()
    }
    
    func styleCell(cell: UITableViewCell) {
        cell.textLabel.font = UIFont(name: UIFont().primaryFont(), size: 20)
        cell.detailTextLabel.font = UIFont(name: UIFont().heavyFont(), size: 14)
        
        cell.textLabel.textColor = UIColor().darkColor()
        cell.detailTextLabel.textColor = UIColor().lighterColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set nav bar title.
        self.title = ingredient.name
        
        // Tell table to look at this class for info.
        self.brandsTableView.delegate = self
        self.brandsTableView.dataSource = self
        self.brandsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "brandCell")
        
        // Tell table to look at this class for info.
        self.drinksTableView.delegate = self
        self.drinksTableView.dataSource = self
        self.drinksTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "drinkCell")

        // Give our labels some text.
        self.ingredientNameLabel.text = ingredient.name
        self.ingredientDescriptionLabel.text = ingredient.description
        self.brandTableLabel.text = "Recommended \(ingredient.name) brands"
        self.drinksTableLabel.text = "Drinks containing \(ingredient.name)"
        
        self.viewDidLayoutSubviews()
        
        if ingredient.description == "" {
            self.ingredientDescriptionLabel.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
        
        if ingredient.brands.count == 0 {
            self.brandTableLabel.removeFromSuperview()
            self.brandsTableView.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
        
        styleController()
    }

    override func styleController() {
        super.styleController()
        
        self.scrollView.backgroundColor = UIColor().backgroundColor()
        
        self.ingredientNameLabel.textColor = UIColor().darkColor()
        self.ingredientNameLabel.font = UIFont(name: UIFont().heavyFont(), size: 32)
        self.ingredientNameLabel.textAlignment = NSTextAlignment.Center
        
        self.ingredientDescriptionLabel.textColor = UIColor().darkColor()
        self.ingredientDescriptionLabel.font = UIFont(name: UIFont().primaryFont(), size: 15)
        
        for label in [self.brandTableLabel, self.drinksTableLabel] {
            label.font = UIFont(name: UIFont().heavyFont(), size: 15)
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor().lightColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func setIngredient(ingredient: IngredientBase) {
        self.ingredient = ingredient
        self.recipes = AllRecipes.sharedInstance.filter({ $0.matchesTerms([self.ingredient.name.lowercaseString as NSString]) })
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        
        let destination = segue!.destinationViewController as RecipeDetailViewController
        
        var recipe = getSelectedRecipe()
        destination.setRecipe(recipe)
    }
    
    func getSelectedRecipe() -> Recipe {
        return recipes[self.drinksTableView.indexPathForSelectedRow().row]
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if tableView == self.drinksTableView {
            self.performSegueWithIdentifier("recipeDetail", sender: nil)
        }
    }
    
}
