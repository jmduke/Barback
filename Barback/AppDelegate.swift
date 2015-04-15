//
//  AppDelegate.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import AdSupport
import CoreData
import Crashlytics
import Fabric
import Parse
import ParseCrashReporting
import SystemConfiguration
import UIKit

func isConnectedToInternet() -> Bool {
    let reachability = Reachability.reachabilityForInternetConnection()
    let networkStatus = reachability.currentReachabilityStatus()
    let notReachableStatus = 0
    return networkStatus.rawValue != notReachableStatus
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        // Format of `barback://recipe/<RecipeName>`.
        if (url.host?.lowercaseString == Recipe.parseClassName().lowercaseString) {
            let recipeName = url.path?.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
            if let recipeName = recipeName {
                    let recipe = Recipe.forName(recipeName)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller: RecipeDetailViewController = storyboard.instantiateViewControllerWithIdentifier("recipeDetail") as! RecipeDetailViewController
                    controller.setRecipeForController(recipe)

                    let tabBarController = self.window?.rootViewController as! UITabBarController
                    let navController = tabBarController.selectedViewController as! UINavigationController
                    navController.pushViewController(controller, animated: true)
            }
        }

        return true
    }
    
    var tabBarItems: [UITabBarItem] {
        get {
            let tabBarController = self.window?.rootViewController as! UITabBarController
            let tabBar = tabBarController.tabBar
            let items = tabBar.items as! [UITabBarItem]
            return items
        }
    }
    
    var privateKeys: NSDictionary = {
        let keychain = NSBundle.mainBundle().pathForResource("PrivateKeys", ofType: "plist")
        return NSDictionary(contentsOfFile: keychain!)!
    }()
    
    // Needed to access UITabBarIcons.
    var window: UIWindow?
    
    func updateIfNecessary() {
        if isFirstTimeAppLaunched() {
            finalizeAppSetup()
        }
    }
    
    func onOldVersion() -> Bool {
        let oldRecipes = IngredientBase.all().filter({ ($0 as IngredientBase).color == nil }).count
        return (oldRecipes == 0)
    }
 
    func finalizeAppSetup() {
        markAppAsLaunched()
        updateVersionOfApp()
        
        // Set some random recipes to be favorites.
        let initialNumberOfFavoritedRecipes = 3
        for _ in 1...initialNumberOfFavoritedRecipes {
            var randomRecipe = Recipe.random()
            randomRecipe.favorite = true
        }
        
        
        enableAppInteraction()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackgroundWithBlock(nil)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics()])
        initializeDependencies(launchOptions)
        
        // Register for push notifications.
        let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        updateIfNecessary()
        styleApp()
        
        return true
    }
    
    func enableAppInteraction() {
        if !runningOnIPad() {
            for tabBarItem in tabBarItems {
                tabBarItem.enabled = true
            }
        }
    }
    
    func disableAppInteraction() {
        if !runningOnIPad() {
            for tabBarItem in tabBarItems {
                tabBarItem.enabled = false
            }
        }
    }
    
    func styleApp() {
        // Set status bar to active.  And white.
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        if !runningOnIPad() {
            // Set font of tab bar items.
            var tabBarAttributes = NSMutableDictionary(dictionary: [:])
            tabBarAttributes.setValue(
                UIFont(name: UIFont.primaryFont(), size: 10), forKey: NSFontAttributeName)
            UITabBarItem.appearance().setTitleTextAttributes(tabBarAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)
            
            let imageColor = Color.Light.toUIColor()
            
            if tabBarItems.count > 3 {
                tabBarItems[0].image = BezierImage.Glass.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[1].image = BezierImage.Search.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[2].image = BezierImage.Favorited.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[3].image = BezierImage.Random.path().toImageWithStrokeColor(imageColor, fillColor: nil)
            }
        }
    }

    func initializeDependencies(launchOptions: NSDictionary?) {
        // Initialize Parse.
        let parseApplicationId = privateKeys["parseApplicationId"]! as! String
        let parseClientKey = privateKeys["parseClientKey"]! as! String
        ParseCrashReporting.enable()
        Recipe.registerSubclass()
        Ingredient.registerSubclass()
        IngredientBase.registerSubclass()
        Brand.registerSubclass()
        Parse.enableLocalDatastore()
        Parse.setApplicationId(parseApplicationId, clientKey: parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions as? [NSObject : AnyObject], block: nil)
        
        
        PFObject.unpinAll(Recipe.all(true))
        PFObject.unpinAll(Ingredient.all(true))
        PFObject.unpinAll(IngredientBase.all(true))
        PFObject.unpinAll(Brand.all(true))
        PFObject.pinAll(Recipe.all(false))
        PFObject.pinAll(Ingredient.all(false))
        PFObject.pinAll(IngredientBase.all(false))
        PFObject.pinAll(Brand.all(false))
        
        // Initialize Appirater.
        Appirater.setAppId("829469529")
        Appirater.setDaysUntilPrompt(7)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)
    }

}

