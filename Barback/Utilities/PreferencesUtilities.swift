//
//  PreferencesUtilities.swift
//  Barback
//
//  Created by Justin Duke on 11/25/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

func userWantsImperialUnits() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey("useImperialUnits")
}

func registerSettingsDefaults() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    if (!userDefaults.boolForKey("useImperialUnits")) {
        let appDefaults = ["useImperialUnits": true]
        userDefaults.registerDefaults(appDefaults)
        userDefaults.synchronize()
    }
}

func runningOnIPad() -> Bool {
    return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
}

func getRecipeDetailController(segue: UIStoryboardSegue?) -> RecipeDetailViewController {
    if runningOnIPad() {
        return segue!.destinationViewController.topViewController as RecipeDetailViewController
    } else {
        return segue!.destinationViewController as RecipeDetailViewController
    }
}