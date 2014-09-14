//
//  IngredientDetailViewController.swift
//  
//
//  Created by Justin Duke on 6/22/14.
//
//

import UIKit

class IngredientDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var ingredientNameLabel : UILabel!
    @IBOutlet var ingredientDescriptionLabel : UILabel!
    @IBOutlet var brandTableLabel : UILabel!
    @IBOutlet var drinksTableLabel : UILabel!
    @IBOutlet var brandsTableView : UITableView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var drinksTableView : UITableView!
    @IBOutlet var drinkTableViewHeight : NSLayoutConstraint!
    @IBOutlet var brandTableViewHeight : NSLayoutConstraint!
    
    var ingredient: IngredientBase
    var recipes: [Recipe]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.ingredient = IngredientBase()
        self.recipes = [Recipe]()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder!) {
        self.ingredient = IngredientBase()
        self.recipes = [Recipe]()
        super.init(coder: aDecoder)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.drinksTableView) {
            return recipes.count
        }
        else {
            return ingredient.brands.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        var cellIdentifier: String
        var primaryText: String
        var detailText: String
        
        if (tableView == drinksTableView) {
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
        
        cell!.textLabel?.text = primaryText
        cell!.detailTextLabel?.text = detailText
        cell!.stylePrimary()
        
        return cell!
    }
    
    override func viewDidLayoutSubviews()  {
        
        if (brandTableViewHeight != nil) {
            let correctBrandsHeight = brandsTableView.contentSize.height
            brandTableViewHeight.constant = correctBrandsHeight
        }
        
        let correctDrinksHeight = drinksTableView.contentSize.height
        drinkTableViewHeight.constant = correctDrinksHeight
        
        view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ingredient.name
        
        brandsTableView.delegate = self
        brandsTableView.dataSource = self
        brandsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "brandCell")
        
        drinksTableView.delegate = self
        drinksTableView.dataSource = self
        drinksTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "drinkCell")

        ingredientNameLabel.text = ingredient.name
        ingredientDescriptionLabel.text = ingredient.description
        brandTableLabel.text = "Recommended \(ingredient.name) brands"
        drinksTableLabel.text = "Drinks containing \(ingredient.name)"
        
        viewDidLayoutSubviews()
        
        if ingredient.description == "" {
            self.ingredientDescriptionLabel.removeFromSuperview()
            view.layoutIfNeeded()
        }
        
        if ingredient.brands.count == 0 {
            brandTableLabel.removeFromSuperview()
            brandsTableView.removeFromSuperview()
            view.layoutIfNeeded()
        }
        
        styleController()
    }

    override func styleController() {
        super.styleController()
        
        scrollView.backgroundColor = UIColor.backgroundColor()
        
        ingredientNameLabel.textColor = UIColor.darkColor()
        ingredientNameLabel.font = UIFont(name: UIFont.heavyFont(), size: 32)
        ingredientNameLabel.textAlignment = NSTextAlignment.Center
        
        ingredientDescriptionLabel.textColor = UIColor.darkColor()
        ingredientDescriptionLabel.font = UIFont(name: UIFont.primaryFont(), size: 15)
        
        for label in [self.brandTableLabel, self.drinksTableLabel] {
            label.font = UIFont(name: UIFont.heavyFont(), size: 15)
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.lightColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setIngredient(ingredient: IngredientBase) {
        self.ingredient = ingredient
        recipes = AllRecipes.sharedInstance.filter({ $0.matchesTerms([ingredient.name.lowercaseString as NSString]) })
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        
        let destination = segue!.destinationViewController as RecipeDetailViewController
        
        var recipe = getSelectedRecipe()
        destination.setRecipe(recipe)
    }
    
    func getSelectedRecipe() -> Recipe {
        let selectedRow = drinksTableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        return recipes[rowIndex!]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if tableView == drinksTableView {
            performSegueWithIdentifier("recipeDetail", sender: nil)
        }
    }
    
}
