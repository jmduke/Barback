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
    
    var brands: [Brand] {
        get {
            let brands = IngredientBase.forName(ingredient.name)!.brands
            let brandObjects = brands.allObjects as [Brand]
            return brandObjects.sorted({$0.price.intValue < $1.price.intValue}).filter({$0.isDead == false})
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.ingredient = IngredientBase.forName("Gin")!
        self.recipes = [Recipe]()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.ingredient = IngredientBase.forName("Gin")!
        self.recipes = [Recipe]()
        super.init(coder: aDecoder)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.drinksTableView) {
            return recipes.count
        }
        else {
            return brands.count
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
            
            cell = StyledCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: cellIdentifier)
        }
        else {
            cellIdentifier = "brandCell"
            
            let brand = brands[indexPath.row]
            primaryText = brand.name
            detailText = String(brand.detailDescription)
            
            cell = StyledCell(style: UITableViewCellStyle.Value1,
                reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel?.text = primaryText
        cell!.detailTextLabel?.text = detailText
        
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
        ingredientDescriptionLabel.text = ingredient.information
        brandTableLabel.text = "Recommended \(ingredient.name) brands"
        drinksTableLabel.text = "Drinks containing \(ingredient.name)"
        
        viewDidLayoutSubviews()
        
        if ingredient.information == "" {
            self.ingredientDescriptionLabel.removeFromSuperview()
            view.layoutIfNeeded()
        }
        
        if brands.count == 0 {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setIngredient(ingredient: IngredientBase) {
        self.ingredient = ingredient
        recipes = Recipe.all().filter({ $0.usesIngredient(ingredient) }).sorted({ $0.name < $1.name })
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
        } else if tableView == brandsTableView {            
            let selectedBrand = brands[indexPath.row]
            
            let image = UIImage(urlString: selectedBrand.imageUrl)!
            
            if image.hasImage() {
                let resizedImage = image.scaleDownToWidth(view.frame.width * 0.5)
                let imageView = UIImageView(image: resizedImage)

                let modal = RNBlurModalView(viewController: self, view: imageView)
                modal.show()
            } else {
                let modal = RNBlurModalView(viewController: self, title: "Image not found", message: "Sorry, we don't have a picture for \(selectedBrand.name) :(.")
                modal.show()
            }
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
