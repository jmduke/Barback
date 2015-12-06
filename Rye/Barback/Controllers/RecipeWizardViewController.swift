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


class RecipeWizardViewController: UIViewController, HasCoachMarks {
    
    @IBOutlet weak var secondBaseSegmentedControl: IngredientBasesSegmentControl!
    @IBOutlet weak var firstBaseSegmentedControl: IngredientBasesSegmentControl!
    
    @IBOutlet weak var secondAdjectiveSegmentedControl: AdjectivesSegmentControl!
    @IBOutlet weak var firstAdjectiveSegmentedControl: FlavorsSegmentControl!

    @IBOutlet weak var recipeSelectionButton: SimpleButton!
    
    var recipeSelector: RecipeSelector = RecipeSelector()
    
    func coachMarksForController() -> [CoachMark] {
        return [
            CoachMark(rect: firstBaseSegmentedControl.frame.union(secondBaseSegmentedControl.frame), caption: "Tell us a type of cocktail you're in the market for..."),
            CoachMark(rect: firstAdjectiveSegmentedControl.frame, caption: "...and what flavor you're into..."),
            CoachMark(rect: secondAdjectiveSegmentedControl.frame, caption: "...and what kinda mood you're in."),
            CoachMark(rect: recipeSelectionButton.frame, caption: "Then we'll fix you up good.")
        ]
    }
    
    override func viewDidLoad() {
        firstBaseSegmentedControl.addTarget(self, action: "selectBase:", forControlEvents: UIControlEvents.ValueChanged)
        secondBaseSegmentedControl.addTarget(self, action: "selectBase:", forControlEvents: UIControlEvents.ValueChanged)
        firstAdjectiveSegmentedControl.addTarget(self, action: "updateAdjectives", forControlEvents: UIControlEvents.ValueChanged)
        
        recipeSelectionButton.addTarget(self, action: "pickRecipe", forControlEvents: UIControlEvents.TouchUpInside)
        
        firstBaseSegmentedControl.baseGroups = [
            IngredientBaseGroup.Gin,
            IngredientBaseGroup.Whiskey
        ]
        secondBaseSegmentedControl.baseGroups = [
            IngredientBaseGroup.Vodka,
            IngredientBaseGroup.Tequila
        ]
        updateAdjectives()
        
        styleController()
        title = "Barkeep"
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        runCoachMarks(view)
    }
    
    func updateAdjectives() {
        let baseGroup = firstBaseSegmentedControl.selectedBase ?? secondBaseSegmentedControl.selectedBase!
        let flavor = firstAdjectiveSegmentedControl.selectedFlavor
        secondAdjectiveSegmentedControl.adjectives = RecipeSelector().getPossibleAdjectives(baseGroup, flavor: flavor)
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
        
        let baseGroup = firstBaseSegmentedControl.selectedBase ?? secondBaseSegmentedControl.selectedBase!
        let adjective = secondAdjectiveSegmentedControl.selectedAdjective
        let flavor = firstAdjectiveSegmentedControl.selectedFlavor
        let recipes = recipeSelector.getRecipes(adjective, flavor: flavor, baseGroup: baseGroup)
        
        let recipe = recipes[Int(arc4random_uniform(UInt32(recipes.count)))]
        recipeSelector.recipeBlacklist.append(recipe)
        return recipe
    }
    
    func pickRecipe() {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)

        Async.main {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Thinking."
            Async.background {
                sleep(1)
                loadingNotification.labelText = "Mixing."
                sleep(1)
                loadingNotification.labelText = "Tasting."
                sleep(1)
                Async.main {
                    loadingNotification.hide(true)
                    self.performSegueWithIdentifier(R.segue.recipeDetail, sender: self)
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let destinationController = getRecipeDetailController(segue)
        destinationController.recipe = getRecipe()
        
        
        let selectedBaseGroup = firstBaseSegmentedControl.selectedBase ?? secondBaseSegmentedControl.selectedBase!
        destinationController.shareOverride = "Asked @GetBarback to make me something \(firstAdjectiveSegmentedControl.selectedFlavor) and \(secondAdjectiveSegmentedControl.selectedAdjective) with \(selectedBaseGroup) -- they made me a \(destinationController.recipe!.name)!"
    }
}