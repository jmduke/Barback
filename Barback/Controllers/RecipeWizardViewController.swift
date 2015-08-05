//
//  RecipeWizardViewController.swift
//  Barback
//
//  Created by Justin Duke on 5/21/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import MBProgressHUD
import SafariServices
import UIKit

class RecipeWizardViewController: UIViewController {
    
    @IBOutlet weak var secondBaseSegmentedControl: SegmentControl!
    @IBOutlet weak var firstBaseSegmentedControl: SegmentControl!
    
    @IBOutlet weak var secondAdjectiveSegmentedControl: SegmentControl!
    @IBOutlet weak var firstAdjectiveSegmentedControl: SegmentControl!

    @IBOutlet weak var recipeSelectionButton: SimpleButton!

    var recipe: Recipe?

    var selectedBase: IngredientBase? {
        didSet {
            self.updateAdjectives()
        }
    }
    var selectedFlavor: Flavor = Flavor.Sweet {
        didSet {
            self.updateAdjectives()
        }
    }
    var selectedAdjective: Adjective = Adjective.Bold
    
    var possibleAdjectives: [Adjective] = [] {
        didSet {
            let adjectiveCells = min(self.possibleAdjectives.count, 3)
            (0..<adjectiveCells).map {
                self.secondAdjectiveSegmentedControl.setTitle(self.possibleAdjectives[$0].description, forSegmentAtIndex: $0)
            }
            (adjectiveCells..<3).map {
                (i: Int) -> () in
                self.secondAdjectiveSegmentedControl.setTitle("", forSegmentAtIndex: i)
                self.secondAdjectiveSegmentedControl.setEnabled(false, forSegmentAtIndex: i)
            }
        }
    }
    
    lazy var bases: [IngredientBase] = [
        IngredientBase.self.forName("Rye")!,
        IngredientBase.self.forName("Bourbon")!,
        IngredientBase.self.forName("Whiskey")!,
        IngredientBase.self.forName("Vodka")!,
        IngredientBase.self.forName("Tequila")!,
        IngredientBase.self.forName("Gin")!
        ]
    
    override func viewDidLoad() {
        selectedBase = IngredientBase.forName("Rye")
        firstBaseSegmentedControl.addTarget(self, action: "selectBase:", forControlEvents: UIControlEvents.ValueChanged)
        secondBaseSegmentedControl.addTarget(self, action: "selectBase:", forControlEvents: UIControlEvents.ValueChanged)
        firstAdjectiveSegmentedControl.addTarget(self, action: "selectFlavor", forControlEvents: UIControlEvents.ValueChanged)
        
        recipeSelectionButton.addTarget(self, action: "pickRecipe", forControlEvents: UIControlEvents.TouchUpInside)
        
        (0...2).map {
            (i: Int) -> () in
            self.firstBaseSegmentedControl.setTitle(self.bases[i].name, forSegmentAtIndex: i)
            self.secondBaseSegmentedControl.setTitle(self.bases[i + 3].name, forSegmentAtIndex: i)
            self.firstAdjectiveSegmentedControl.setTitle(Flavor.all()[i].rawValue, forSegmentAtIndex: i)
            self.secondAdjectiveSegmentedControl.setTitle(Adjective.all()[i].description, forSegmentAtIndex: i)
        }
        
        styleController()
        title = "Bartender"
    }
    
    func updateAdjectives() {
        let recipes = selectedBase!.uses().map({ $0.recipe! })
        let candidates = recipes.filter({ self.selectedFlavor.describesRecipe($0) })
        self.possibleAdjectives = Adjective.all().filter {
            (adjective: Adjective) -> Bool in
            candidates.filter {
                (recipe: Recipe) -> Bool in
                adjective.describesRecipe(recipe)
                }.count > 0
        }
    }

    func selectBase(sender: SegmentControl) {
        let baseName = secondBaseSegmentedControl.selectedSegmentIndex > -1 ? secondBaseSegmentedControl.titleForSegmentAtIndex(secondBaseSegmentedControl.selectedSegmentIndex)! : firstBaseSegmentedControl.titleForSegmentAtIndex(firstBaseSegmentedControl.selectedSegmentIndex)!
        selectedBase = IngredientBase.forName(baseName)

        
        if (sender == firstBaseSegmentedControl) {
            secondBaseSegmentedControl.selectedSegmentIndex = -1
        }
        if (sender == secondBaseSegmentedControl) {
            firstBaseSegmentedControl.selectedSegmentIndex = -1
        }
    }
    
    func selectFlavor() {
        selectedFlavor = Flavor.all()[firstAdjectiveSegmentedControl.selectedSegmentIndex]
    }
    
    func getRecipe() -> Recipe {
        let recipes = selectedBase!.uses().map({ $0.recipe })
        let candidates = recipes.filter({ self.selectedFlavor.describesRecipe($0!) }).filter({ self.selectedAdjective.describesRecipe($0!) })
        
        if (candidates.count > 0) {
            return candidates[Int(arc4random_uniform(UInt32(candidates.count)))]!
        } else {
            return Recipe.forName("Manhattan")!
        }
    }
    
    func pickRecipe() {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        Async.main {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Thinking."
            }.background {
                self.recipe = self.getRecipe()
                sleep(1)
                loadingNotification.labelText = "Mixing."
                sleep(1)
                loadingNotification.labelText = "Tasting."
                sleep(1)
            }.main {
                MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
                self.performSegueWithIdentifier(R.segue.recipeDetail, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let destinationController = getRecipeDetailController(segue)
        destinationController.setRecipeAs(recipe)
    }
}