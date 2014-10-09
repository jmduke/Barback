//
//  AppDelegate.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    lazy var coreDataHelper: CoreDataHelper = {
        let cdh = CoreDataHelper()
        return cdh
        }()
    
    lazy var coreDataStore: CoreDataStore = {
        let cds = CoreDataStore()
        return cds
        }()
    
    var tabBarController: UITabBarController?
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") || true {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey:"HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let context = self.coreDataHelper.managedObjectContext!
            
            // Load up Core Data with all of our goodies.
            for ingredientBase: JSONIngredientBase in AllIngredients.sharedInstance.values {
                let newBase: CIngredientBase = NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: context) as CIngredientBase
                newBase.name = ingredientBase.name
                newBase.information = ingredientBase.description
                newBase.type = ingredientBase.type.toRaw()
                let newBrands = newBase.mutableSetValueForKey("brands")
                for brand in ingredientBase.brands {
                    let newBrand: CBrand = NSEntityDescription.insertNewObjectForEntityForName("Brand", inManagedObjectContext: context) as CBrand
                    newBrand.name = brand.name
                    newBrand.price = brand.price
                    newBrands.addObject(newBrand)
                }
            }
            
            self.coreDataHelper.saveContext(context)
            
            for recipe in AllRecipes.sharedInstance {
                let newRecipe: CRecipe = NSEntityDescription.insertNewObjectForEntityForName("Recipe", inManagedObjectContext: context) as CRecipe
                newRecipe.name = recipe.name
                newRecipe.directions = recipe.directions
                newRecipe.isFavorited = false
                let newIngredients = newRecipe.mutableSetValueForKey("ingredients")
                for ingredient in recipe.ingredients {
                    let newIngredient: CIngredient = NSEntityDescription.insertNewObjectForEntityForName("Ingredient", inManagedObjectContext: context) as CIngredient
                    
                    var ingredientBase: CIngredientBase? = CIngredientBase.forName(ingredient.base.name)
                    if ingredientBase == nil {
                        ingredientBase = (NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: context) as CIngredientBase)
                        ingredientBase!.name = ingredient.base.name
                    }
                    
                    let ingredientBaseUses = ingredientBase!.mutableSetValueForKey("uses")
                    
                    newIngredient.base = ingredientBase!
                    newIngredient.amount = ingredient.amount
                    newIngredient.label = ingredient.label
                    newIngredient.isSpecial = ingredient.isSpecial
                    newIngredient.recipe = newRecipe
                    
                    newIngredients.addObject(newIngredient)
                    ingredientBaseUses.addObject(newIngredient)
                    self.coreDataHelper.saveContext(context)
                }
            }
            
            self.coreDataHelper.saveContext(context)
            
            // Set some random recipes to be favorites.
            let initialNumberOfFavoritedRecipes = 3
            for _ in 1...initialNumberOfFavoritedRecipes {
                CRecipe.random().isFavorited = true
            }
        }
        
        // Set status bar to active.  And white.
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // Set font of tab bar items.
        var tabBarAttributes = NSMutableDictionary(dictionary: [:])
        tabBarAttributes.setValue(
            UIFont(name: UIFont.primaryFont(), size: 10), forKey: NSFontAttributeName)
        UITabBarItem.appearance().setTitleTextAttributes(tabBarAttributes, forState: UIControlState.Normal)
        
        // Configure review-nagger.
        Appirater.setAppId("829469529")
        Appirater.setDaysUntilPrompt(7)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)
        
        
        
        /*
        let newItem: CBrand = NSEntityDescription.insertNewObjectForEntityForName("Brand", inManagedObjectContext: self.coreDataHelper.backgroundContext!) as CBrand
        newItem.name = "Beefeater London Dry"
        newItem.price = 2
        
        self.coreDataHelper.saveContext(self.coreDataHelper.backgroundContext!)
        
        let request = NSFetchRequest(entityName: "Brand")
        request.predicate = NSPredicate(format: "name CONTAINS 'B'")
        
        let result = coreDataHelper.managedObjectContext!.executeFetchRequest(request, error: nil)
        for resultItem in result! {
            let item = resultItem as CBrand
            print("\(item.name) \(item.price)")
        }*/
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        

        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        coreDataHelper.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        coreDataHelper.saveContext()
    }


}

