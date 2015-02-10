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
    @IBOutlet var brandTableLabel : UILabel!
    @IBOutlet var ingredientAbvLabel: DescriptionLabel!
    @IBOutlet var drinksTableLabel : UILabel!
    @IBOutlet var brandsTableView : UITableView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var drinksTableView : UITableView!
    @IBOutlet var drinkTableViewHeight : NSLayoutConstraint!
    @IBOutlet var brandTableViewHeight : NSLayoutConstraint!
    @IBOutlet var ingredientDescriptionView: DescriptionTextView!
    
    @IBOutlet weak var wikipediaButton: SimpleButton!
    @IBOutlet weak var cocktailDBButton: SimpleButton!

    
    var ingredient: IngredientBase
    var recipes: [Recipe]
    
    var brands: [Brand] {
        get {
            let brands = ingredient.brands
            let brandObjects = brands.allObjects as [Brand]
            return brandObjects.sorted({$0.price.intValue < $1.price.intValue}).filter({$0.isDead != true})
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
        
        if ingredient.cocktaildb != nil && ingredient.cocktaildb != "" {
            cocktailDBButton.setTitle("\(ingredient.name) on CocktailDB", forState: UIControlState.Normal)
            cocktailDBButton.addTarget(self, action: "openCocktailDBPage", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            cocktailDBButton.removeFromSuperview()
        }
        
        
        wikipediaButton.setTitle("\(ingredient.name) on Wikipedia", forState: UIControlState.Normal)
        wikipediaButton.addTarget(self, action: "openWikipediaPage", forControlEvents: UIControlEvents.TouchUpInside)
        
        if Int(ingredient.abv) > 0 {
            ingredientAbvLabel.text = Int(ingredient.abv) > 0 ? "\(ingredient.abv)% ABV" : "(non-alcoholic)"
        } else {
            ingredientAbvLabel.removeFromSuperview()
        }
        
        ingredientDescriptionView.text = ingredient.information
        brandTableLabel.text = "Recommended \(ingredient.name) brands"
        drinksTableLabel.text = "Drinks containing \(ingredient.name)"
        
        ingredientDescriptionView.sizeToFit()
        ingredientDescriptionView.layoutIfNeeded()
        
        viewDidLayoutSubviews()
        
        if ingredient.information == "" {
            self.ingredientDescriptionView.removeFromSuperview()
            view.layoutIfNeeded()
        }
        
        if brands.count == 0 {
            brandTableLabel.removeFromSuperview()
            brandsTableView.removeFromSuperview()
            view.layoutIfNeeded()
        }
        
        styleController()
    }
    
    func popWebView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openCocktailDBPage() {
        let url = NSURL(string: ingredient.cocktaildb!)!
        let controller = UIWebViewController(url: url, title: "CocktailDB", cancelSelector: "popWebView", parent: self)
        navigationController!.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func openWikipediaPage() {
        let urlString = "http://en.wikipedia.org/wiki/\(ingredient.name)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: urlString!)!
        let controller = UIWebViewController(url: url, title: "Wikipedia", cancelSelector: "popWebView", parent: self)
        navigationController!.presentViewController(controller, animated: true, completion: nil)
    }

    override func styleController() {
        super.styleController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setIngredientForController(ingredient: IngredientBase) {
        self.ingredient = ingredient
        recipes = Recipe.all().filter({ $0.usesIngredient(ingredient) }).sorted({ $0.name < $1.name })
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        var destinationController = getRecipeDetailController(segue)
        var recipe = getSelectedRecipe()
        destinationController.setRecipeForController(recipe)
    }
    
    func getSelectedRecipe() -> Recipe {
        let selectedRow = drinksTableView.indexPathForSelectedRow()
        let rowIndex = selectedRow?.row
        return recipes[rowIndex!]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == drinksTableView {
            performSegueWithIdentifier("recipeDetail", sender: nil)
        } else if tableView == brandsTableView {            
            let selectedBrand = brands[indexPath.row]
            
            let image = UIImage(urlString: selectedBrand.url)!
            
            if image.hasImage() {
                let resizedImage = image.scaleDownToWidth(view.frame.width * 0.5)
                let imageView = UIImageView(image: resizedImage)

                let modal = RNBlurModalView(viewController: self, view: imageView)
                modal.show()
            } else {
                let modalMessage = isConnectedToInternet() ? "Sorry, we don't have a picture for \(selectedBrand.name) :(." : "We can't grab the image because you don't have an internet connection :("
                let modal = RNBlurModalView(viewController: self, title: "Image not found", message: modalMessage)
                modal.show()
            }
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
