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

public class IngredientDetailViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var brandsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var drinksTableViewHeight: NSLayoutConstraint!

    @IBOutlet public var headerLabel: IngredientHeaderLabel!
    @IBOutlet public var subheaderLabel: IngredientSubheadLabel!
    @IBOutlet weak var diagramView: IngredientDiagramView!
    @IBOutlet public var descriptionView: IngredientDescriptionTextView!

    @IBOutlet var brandsTableView: BrandTableView!
    @IBOutlet public var drinksTableView: IngredientUsesTableView!
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var wikipediaButton: SimpleButton!
    @IBOutlet weak var cocktailDBButton: IngredientCocktailDBButton!

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let correctBrandsHeight = min(view.bounds.size.height, brandsTableView.contentSize.height)
        brandsTableViewHeight.constant = correctBrandsHeight
        
        if ((drinksTableView) != nil) {
            drinksTableViewHeight.constant = drinksTableView.contentSize.height
            view.layoutIfNeeded()
        }
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
    
    public var ingredient: IngredientBase

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.ingredient = IngredientBase()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        self.ingredient = IngredientBase()
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.ingredient = ingredient
        subheaderLabel.ingredient = ingredient
        descriptionView.ingredient = ingredient
        diagramView.ingredient = ingredient
        cocktailDBButton.ingredient = ingredient
        brandsTableView.ingredient = ingredient
        drinksTableView.ingredient = ingredient
        
        drinksTableView.selectionAction = {
            (path: NSIndexPath) -> Void in
            self.performSegueWithIdentifier(R.segue.recipeDetail, sender: self)
        }
        brandsTableView.selectionAction = {
            (path: NSIndexPath) -> Void in
            self.showBrand(self.ingredient.sortedBrands[path.row])
        }
        
        title = ingredient.name

        wikipediaButton.setTitle("\(ingredient.name) on Wikipedia", forState: UIControlState.Normal)

        cocktailDBButton.addTarget(self, action: "openCocktailDBPage", forControlEvents: UIControlEvents.TouchUpInside)
        wikipediaButton.addTarget(self, action: "openWikipediaPage", forControlEvents: UIControlEvents.TouchUpInside)

        viewDidLayoutSubviews()
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

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override public func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let destinationController = getRecipeDetailController(segue)
        let recipe = getSelectedRecipe()
        destinationController.setRecipeAs(recipe)
    }

    func getSelectedRecipe() -> Recipe {
        let selectedRow = drinksTableView.indexPathForSelectedRow
        let rowIndex = selectedRow?.row
        return ingredient.uses[rowIndex!].recipe!
    }

    public func showBrand(brand: Brand) {
        let image = UIImage(urlString: brand.url)!
        
        if image.hasImage() {
            let resizedImage = image.scaleDownToWidth(view.frame.width * 0.5)
            let imageView = UIImageView(image: resizedImage)
            
            let modal = RNBlurModalView(viewController: self, view: imageView)
            modal.show()
        } else {
            let modalMessage = "Sorry, we don't have a picture for \(brand.name) :(."
            let modal = RNBlurModalView(viewController: self, title: "Image not found", message: modalMessage)
            modal.show()
        }
    }
}
