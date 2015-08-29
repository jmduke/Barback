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
    
    @IBOutlet weak var secondBaseSegmentedControl: IngredientBasesSegmentControl!
    @IBOutlet weak var firstBaseSegmentedControl: IngredientBasesSegmentControl!
    
    @IBOutlet weak var secondAdjectiveSegmentedControl: AdjectivesSegmentControl!
    @IBOutlet weak var firstAdjectiveSegmentedControl: FlavorsSegmentControl!

    @IBOutlet weak var recipeSelectionButton: SimpleButton!
    
    var candidateRecipes: [Recipe] {
        let selectedBase = firstBaseSegmentedControl.selectedBase ?? secondBaseSegmentedControl.selectedBase!
        let recipes = selectedBase.uses.map({ $0.recipe! })
        return recipes.filter({ self.firstAdjectiveSegmentedControl.selectedFlavor.describesRecipe($0) })
    }
    
    override func viewDidLoad() {
        firstBaseSegmentedControl.addTarget(self, action: "selectBase:", forControlEvents: UIControlEvents.ValueChanged)
        secondBaseSegmentedControl.addTarget(self, action: "selectBase:", forControlEvents: UIControlEvents.ValueChanged)
        firstAdjectiveSegmentedControl.addTarget(self, action: "updateAdjectives", forControlEvents: UIControlEvents.ValueChanged)
        
        recipeSelectionButton.addTarget(self, action: "pickRecipe", forControlEvents: UIControlEvents.TouchUpInside)
        
        firstBaseSegmentedControl.bases = [
            IngredientBase.self.forName("Rye")!,
            IngredientBase.self.forName("Bourbon")!,
            IngredientBase.self.forName("Whiskey")!
        ]
        secondBaseSegmentedControl.bases = [
            IngredientBase.self.forName("Vodka")!,
            IngredientBase.self.forName("Tequila")!,
            IngredientBase.self.forName("Gin")!
        ]
        
        styleController()
        title = "Bartender"
    }
    
    func updateAdjectives() {
        secondAdjectiveSegmentedControl.adjectives = Adjective.all().filter {
            (adjective: Adjective) -> Bool in
            candidateRecipes.filter {
                (recipe: Recipe) -> Bool in
                adjective.describesRecipe(recipe)
                }.count > 0
        }
    }

    func selectBase(sender: SegmentControl) {
        if (sender == firstBaseSegmentedControl) {
            secondBaseSegmentedControl.selectedSegmentIndex = -1
        }
        if (sender == secondBaseSegmentedControl) {
            firstBaseSegmentedControl.selectedSegmentIndex = -1
        }
        updateAdjectives()
    }
    
    func getRecipe() -> Recipe {
        let candidates = candidateRecipes.filter({ self.firstAdjectiveSegmentedControl.selectedFlavor.describesRecipe($0) }).filter({ secondAdjectiveSegmentedControl.selectedAdjective.describesRecipe($0) })
        
        if (candidates.count > 0) {
            return candidates[Int(arc4random_uniform(UInt32(candidates.count)))]
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
                sleep(1)
                loadingNotification.labelText = "Mixing."
                sleep(1)
                loadingNotification.labelText = "Tasting."
                sleep(1)
            }.main {
                loadingNotification.hide(true)
                self.performSegueWithIdentifier(R.segue.recipeDetail, sender: self)
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let destinationController = getRecipeDetailController(segue)
        destinationController.setRecipeAs(getRecipe())
    }
}