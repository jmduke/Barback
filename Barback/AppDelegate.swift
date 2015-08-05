//
//  AppDelegate.swift
//  Barback
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import AdSupport
import Appirater
import CoreData
// import Crashlytics
// import Fabric
import MBProgressHUD
import RealmSwift
import SystemConfiguration
import UIKit


func initializeDependencies(launchOptions: NSDictionary?) {

    // Fabric.with([Crashlytics()])

    // Initialize Appirater.
    Appirater.setAppId("829469529")
    Appirater.setDaysUntilPrompt(7)
    Appirater.setUsesUntilPrompt(5)
    Appirater.setSignificantEventsUntilPrompt(-1)
    Appirater.setTimeBeforeReminding(2)
    Appirater.setDebug(false)
    Appirater.appLaunched(true)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {

        // Format of `barback://recipe/<RecipeName>`.
        if (url.host?.lowercaseString == Recipe.parseClassName().lowercaseString) {
            let recipeName = url.path?.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
            if let recipeName = recipeName {
                    let recipe = Recipe.forName(recipeName)
                    let storyboard = R.storyboard.main.instance
                    let controller: RecipeDetailViewController = storyboard.instantiateViewControllerWithIdentifier("recipeDetail") as! RecipeDetailViewController
                    controller.setRecipeAs(recipe)

                    let tabBarController = self.window?.rootViewController as! UITabBarController
                let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
                    navController.pushViewController(controller, animated: true)
            }
        }


        return true
    }

    var tabBarItems: [UITabBarItem] {
        get {
            let tabBarController = self.window?.rootViewController as! UITabBarController
            let tabBar = tabBarController.tabBar
            let items = tabBar.items!
            return items
        }
    }

    // Needed to access UITabBarIcons.
    var window: UIWindow?

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerUserNotificationSettings(notificationSettings)
    }

    func syncData() {
        do {
            let realm = try Realm()
            realm.write {
                realm.deleteAll()
            }
            
            let baseFilepath = NSBundle.mainBundle().pathForResource("bases", ofType: "json")!
            let baseData = try NSData(contentsOfFile: baseFilepath, options: NSDataReadingOptions.DataReadingMappedAlways)
            let baseDict: [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(baseData, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
            realm.write {
                for object in baseDict {
                    realm.add(IngredientBase(value: object))
                }
            }
            
            let recipeFilepath = NSBundle.mainBundle().pathForResource("recipes", ofType: "json")!
            let recipeData = try NSData(contentsOfFile: recipeFilepath, options: NSDataReadingOptions.DataReadingMappedAlways)
            let recipeDict: [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(recipeData, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
            realm.write {
                for object in recipeDict {
                    let recipe = Recipe(value: object)
                    realm.add(recipe)
                    for ingredient: Ingredient in recipe.ingredients {
                        ingredient.base = realm.objects(IngredientBase).filter("name = \"\(ingredient.baseName)\"").first
                        if (ingredient.base == nil) {
                            print(ingredient.baseName)
                        }
                        ingredient.recipe = recipe
                        realm.add(ingredient)
                    }
                }
            }
        } catch {
            print("Error info: \(error)")
        }
    }

    func registerPushNotifications(application: UIApplication) {
        // Register for push notifications.
        let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        initializeDependencies(launchOptions)
        registerPushNotifications(application)
        styleApp()
        syncData()
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
            var tabBarAttributes = [String : AnyObject]()
            tabBarAttributes[NSFontAttributeName] = UIFont(name: UIFont.primaryFont(), size: 10)
            UITabBarItem.appearance().setTitleTextAttributes(tabBarAttributes, forState: UIControlState.Normal)
            
            let imageColor = Color.Light.toUIColor()
            
            if tabBarItems.count > 3 {
                tabBarItems[0].image = BezierImage.Glass.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[1].image = BezierImage.Search.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[2].image = BezierImage.Favorited.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[3].image = BezierImage.Random.path().toImageWithStrokeColor(imageColor, fillColor: nil)
            }
        }
    }

}

