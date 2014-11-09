//
//  AppDelegate.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import AdSupport
import CoreData
import MobileAppTracker
import Parse
import UIKit

func managedContext() -> NSManagedObjectContext {
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    return delegate.coreDataHelper.managedObjectContext!
}

func saveContext() {
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    delegate.coreDataHelper.saveContext(managedContext())
}

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

    func isFirstTimeAppLaunched() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey("launchedOnce")
    }
    
    func dataNeedsSyncing() -> Bool {
        for syncableClass: AnyClass in [Recipe.self, Ingredient.self, IngredientBase.self, Brand.self] {
            let className = NSStringFromClass(syncableClass).componentsSeparatedByString(".").last!
            if !PFQuery.allObjectsSinceSync(className).isEmpty {
                return true
            }
        }
        
        return false
    }
    
    func syncNewData() {
        let ingredientBases = IngredientBase.syncWithParse()
        let recipes = Recipe.syncWithParse()
        let ingredients = Ingredient.syncWithParse()
        let brands = Brand.syncWithParse()
        
        let dateString = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        NSUserDefaults.standardUserDefaults().setObject(dateString, forKey:"syncDate")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func markAppAsLaunched() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey:"launchedOnce")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!)!
        
        // Initialize Parse.
        let parseApplicationId = keys["parseApplicationId"]! as String
        let parseClientKey = keys["parseClientKey"]! as String
        Parse.setApplicationId(parseApplicationId, clientKey: parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        // Initialize MobileAppTracking.
        let matAdvertiserID = keys["matAdvertiserId"]! as String
        let matConversionKey = keys["matConversionKey"]! as String
        MobileAppTracker.initializeWithMATAdvertiserId(matAdvertiserID, MATConversionKey: matConversionKey)
        MobileAppTracker.setAppleAdvertisingIdentifier(ASIdentifierManager.sharedManager().advertisingIdentifier, advertisingTrackingEnabled: ASIdentifierManager.sharedManager().advertisingTrackingEnabled)
        if !isFirstTimeAppLaunched() {
            MobileAppTracker.setExistingUser(true)
        }
        
        
        if dataNeedsSyncing() {
            syncNewData()
            saveContext()
        }
        
        if isFirstTimeAppLaunched() {
            
            // Set some random recipes to be favorites.
            let initialNumberOfFavoritedRecipes = 3
            for _ in 1...initialNumberOfFavoritedRecipes {
                var randomRecipe = managedContext().randomObject(Recipe.self)!
                while (!randomRecipe.isReal) {
                    randomRecipe = managedContext().randomObject(Recipe.self)!
                }
                randomRecipe.favorite = true
            }
            saveContext()

            markAppAsLaunched()
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
        MobileAppTracker.measureSession()

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        coreDataHelper.saveContext()
    }


}

