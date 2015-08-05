//
//  IngredientDetailViewController.swift
//
//
//  Created by Justin Duke on 6/22/14.
//
//

import RNBlurModalView
import SafariServices
import UIKit

public class IngredientDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {

    @IBOutlet public var headerLabel: IngredientHeaderLabel!
    @IBOutlet public var subheaderLabel: IngredientSubheadLabel!
    @IBOutlet weak var diagramView: IngredientDiagramView!
    @IBOutlet public var descriptionView: IngredientDescriptionTextView!

    @IBOutlet var brandTableLabel : UILabel!
    @IBOutlet var drinksTableLabel : UILabel!

    @IBOutlet public var brandsTableView: UITableView!
    @IBOutlet public var drinksTableView: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var drinkTableViewHeight: NSLayoutConstraint!
    @IBOutlet var brandTableViewHeight: NSLayoutConstraint!

    @IBOutlet weak var wikipediaButton: SimpleButton!
    @IBOutlet weak var cocktailDBButton: IngredientCocktailDBButton!


    var ingredient: IngredientBase
    var recipes: [Recipe]

    var brands: [Brand] {
        get {
            let brands = ingredient.brands
            return brands.sort({$0.price < $1.price})
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.ingredient = IngredientBase()
        self.recipes = [Recipe]()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        self.ingredient = IngredientBase()
        self.recipes = [Recipe]()
        super.init(coder: aDecoder)
    }
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.drinksTableView) {
            return recipes.count
        }
        else {
            return brands.count
        }
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        var cellIdentifier: String

        if (tableView == drinksTableView) {
            cellIdentifier = "drinkCell"

            let recipe = recipes[indexPath.row]

            cell = RecipeCell(recipe: recipe, reuseIdentifier: cellIdentifier)
        }
        else {
            cellIdentifier = "brandCell"

            let brand = brands[indexPath.row]
            cell = BrandCell(brand: brand,
                reuseIdentifier: cellIdentifier)
        }

        return cell!
    }

    override public func viewDidLayoutSubviews()  {

        if (brandTableViewHeight != nil) {
            let correctBrandsHeight = brandsTableView.contentSize.height
            brandTableViewHeight.constant = correctBrandsHeight
        }

        let correctDrinksHeight = drinksTableView.contentSize.height
        drinkTableViewHeight.constant = correctDrinksHeight

        
        view.layoutIfNeeded()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.ingredient = ingredient
        subheaderLabel.ingredient = ingredient
        descriptionView.ingredient = ingredient
        diagramView.ingredient = ingredient
        cocktailDBButton.ingredient = ingredient

        
        title = ingredient.name
        
        brandsTableView.delegate = self
        brandsTableView.dataSource = self
        brandsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "brandCell")
        brandsTableView.separatorStyle = UITableViewCellSeparatorStyle.None

        drinksTableView.delegate = self
        drinksTableView.dataSource = self
        drinksTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "drinkCell")
        drinksTableView.separatorStyle = UITableViewCellSeparatorStyle.None

        wikipediaButton.setTitle("\(ingredient.name) on Wikipedia", forState: UIControlState.Normal)

        cocktailDBButton.addTarget(self, action: "openCocktailDBPage", forControlEvents: UIControlEvents.TouchUpInside)
        wikipediaButton.addTarget(self, action: "openWikipediaPage", forControlEvents: UIControlEvents.TouchUpInside)

        brandTableLabel.text = "Recommended \(ingredient.name) brands"
        drinksTableLabel.text = "Drinks containing \(ingredient.name)"

        viewDidLayoutSubviews()

        if brands.isEmpty {
            brandTableLabel.removeFromSuperview()
            brandsTableView.removeFromSuperview()
            view.layoutIfNeeded()
        }

        view.layoutIfNeeded()
        styleController()
    }

    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func openCocktailDBPage() {
        let url = NSURL(string: ingredient.cocktaildb)!
        let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
        vc.delegate = self
        navigationController!.presentViewController(vc, animated: true, completion: nil)

    }

    func openWikipediaPage() {
        let urlString = "http://en.wikipedia.org/wiki/\(ingredient.name)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: urlString!)!
        let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
        vc.delegate = self
        navigationController!.presentViewController(vc, animated: true, completion: nil)
    }

    override func styleController() {
        super.styleController()

    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func setIngredientForController(ingredient: IngredientBase) {
        self.ingredient = ingredient
        recipes = ingredient.uses().map({ $0.recipe! })
    }

    override public func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let destinationController = getRecipeDetailController(segue)
        let recipe = getSelectedRecipe()
        destinationController.setRecipeAs(recipe)
    }

    func getSelectedRecipe() -> Recipe {
        let selectedRow = drinksTableView.indexPathForSelectedRow
        let rowIndex = selectedRow?.row
        return recipes[rowIndex!]
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == drinksTableView {
            performSegueWithIdentifier(R.segue.recipeDetail, sender: nil)
        } else if tableView == brandsTableView {            
            let selectedBrand = brands[indexPath.row]
            
            let image = UIImage(urlString: selectedBrand.url)!
            
            if image.hasImage() {
                let resizedImage = image.scaleDownToWidth(view.frame.width * 0.5)
                let imageView = UIImageView(image: resizedImage)

                let modal = RNBlurModalView(viewController: self, view: imageView)
                modal.show()
            } else {
                let modalMessage = "Sorry, we don't have a picture for \(selectedBrand.name) :(."
                let modal = RNBlurModalView(viewController: self, title: "Image not found", message: modalMessage)
                modal.show()
            }
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
