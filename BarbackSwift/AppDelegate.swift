//
//  AppDelegate.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var tabBarController: UITabBarController?
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey:"HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // Set some random recipes to be favorites.
            let initialNumberOfFavoritedRecipes = 3
            for _ in 1...initialNumberOfFavoritedRecipes {
                Recipe.random().favorited = true
            }
        }
        
        // Set status bar to white.
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // Set font of tab bar items.
        var tabBarAttributes = NSMutableDictionary(dictionary: UITabBarItem.appearance().titleTextAttributesForState(UIControlState.Normal))
        tabBarAttributes.setValue(
            UIFont(name: UIFont().primaryFont(), size: 10), forKey: NSFontAttributeName)
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
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

