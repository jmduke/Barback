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
import SystemConfiguration
import UIKit

func managedContext() -> NSManagedObjectContext {
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    return delegate.coreDataHelper.managedObjectContext!
}

func saveContext() {
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    delegate.coreDataHelper.saveContext(managedContext())
}

func isConnectedToInternet() -> Bool {
    let reachability = Reachability.reachabilityForInternetConnection()
    let networkStatus = reachability.currentReachabilityStatus()
    let notReachableStatus = 0
    return networkStatus.rawValue != notReachableStatus
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var tabBarItems: [UITabBarItem] {
        get {
            let tabBarController = self.window?.rootViewController as UITabBarController
            let tabBar = tabBarController.tabBar
            let items = tabBar.items as [UITabBarItem]
            return items
        }
    }
    
    var privateKeys: NSDictionary = {
        let keychain = NSBundle.mainBundle().pathForResource("PrivateKeys", ofType: "plist")
        return NSDictionary(contentsOfFile: keychain!)!
    }()
    
    lazy var coreDataHelper: CoreDataHelper = {
        let cdh = CoreDataHelper()
        return cdh
        }()
    
    lazy var coreDataStore: CoreDataStore = {
        let cds = CoreDataStore()
        return cds
        }()
    
    // Needed to access UITabBarIcons.
    var window: UIWindow?
    
    
    func updateIfNecessary() {
        if isFirstTimeAppLaunched() {
            finalizeAppSetup()
        } else if dataNeedsSyncing() {
            syncNewData()
            saveContext()
            
        }
        
        markAppAsLaunched()
    }
    
    func finalizeAppSetup() {
        syncNewData()
        saveContext()
        
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
        
        tabBarItems[1].enabled = true
        tabBarItems[2].enabled = true
        tabBarItems[3].enabled = true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackgroundWithBlock(nil)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        initializeDependencies(launchOptions)
        
        // Register for push notifications.
        if (application.respondsToSelector("registerUserNotificationSettings")) {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        // Handle launching the application with a bad connection.
        let reachability = Reachability.reachabilityForInternetConnection()
        reachability.reachableBlock = {
            (r: Reachability!) -> Void in
            let _ = Async.main {
                self.updateIfNecessary()
            }
        }
        reachability.startNotifier()
        if isConnectedToInternet() {
            updateIfNecessary()
        } else if isFirstTimeAppLaunched() {
            tabBarItems[1].enabled = false
            tabBarItems[2].enabled = false
            tabBarItems[3].enabled = false
        }
        
        styleApp()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
        coreDataHelper.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        MobileAppTracker.measureSession()

    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataHelper.saveContext()
    }
    
    func styleApp() {
        // Set status bar to active.  And white.
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // Set font of tab bar items.
        var tabBarAttributes = NSMutableDictionary(dictionary: [:])
        tabBarAttributes.setValue(
            UIFont(name: UIFont.primaryFont(), size: 10), forKey: NSFontAttributeName)
        UITabBarItem.appearance().setTitleTextAttributes(tabBarAttributes, forState: UIControlState.Normal)
        
        tabBarItems[0].image = UIBezierPath.glassButton().toImageWithStrokeColor(UIColor.lightColor(), fillColor: nil)
        tabBarItems[1].image = UIBezierPath.searchButton().toImageWithStrokeColor(UIColor.lightColor(), fillColor: nil)
        tabBarItems[2].image = UIBezierPath.favoritedButton().toImageWithStrokeColor(UIColor.lightColor(), fillColor: nil)
        tabBarItems[3].image = UIBezierPath.randomButton().toImageWithStrokeColor(UIColor.lightColor(), fillColor: nil)
    }

    func initializeDependencies(launchOptions: NSDictionary?) {
        // Initialize Parse.
        let parseApplicationId = privateKeys["parseApplicationId"]! as String
        let parseClientKey = privateKeys["parseClientKey"]! as String
        Parse.setApplicationId(parseApplicationId, clientKey: parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        // Initialize MobileAppTracking.
        let matAdvertiserID = privateKeys["matAdvertiserId"]! as String
        let matConversionKey = privateKeys["matConversionKey"]! as String
        MobileAppTracker.initializeWithMATAdvertiserId(matAdvertiserID, MATConversionKey: matConversionKey)
        MobileAppTracker.setAppleAdvertisingIdentifier(ASIdentifierManager.sharedManager().advertisingIdentifier, advertisingTrackingEnabled: ASIdentifierManager.sharedManager().advertisingTrackingEnabled)
        if !isFirstTimeAppLaunched() {
            MobileAppTracker.setExistingUser(true)
        }
        
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

