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

let mostRecentRecipeFavoritedKey = "mostRecentRecipeFavorited"
func setMostRecentRecipeFavorited(recipeName: String) {
    NSUserDefaults.standardUserDefaults().setValue(recipeName, forKey:mostRecentRecipeFavoritedKey)
    NSUserDefaults.standardUserDefaults().synchronize()
}
func getMostRecentRecipeFavorited() -> String? {
    return NSUserDefaults.standardUserDefaults().stringForKey(mostRecentRecipeFavoritedKey)
}

let mostRecentRecipeFavoritedTimestampKey = "mostRecentRecipeFavoritedTimestamp"
func setMostRecentRecipeFavoritedTimestamp() {
    let timestamp = NSDate().timeIntervalSince1970
    let timestampAsDouble = timestamp.advancedBy(0)
    NSUserDefaults.standardUserDefaults().setDouble(timestampAsDouble, forKey: mostRecentRecipeFavoritedTimestampKey)
    NSUserDefaults.standardUserDefaults().synchronize()
}
func getMostRecentRecipeFavoritedTimestamp() -> NSDate? {
    let timestampAsDouble = NSUserDefaults.standardUserDefaults().doubleForKey(mostRecentRecipeFavoritedTimestampKey)
    let timestamp = NSDate(timeIntervalSince1970: timestampAsDouble)
    return timestamp
}

let mostRecentSearchKey = "mostRecentSearch"
func setMostRecentSearch(searchTerm: String) {
    NSUserDefaults.standardUserDefaults().setValue(searchTerm, forKey:mostRecentSearchKey)
    NSUserDefaults.standardUserDefaults().synchronize()
}
func getMostRecentSearch() -> String? {
    return NSUserDefaults.standardUserDefaults().stringForKey(mostRecentSearchKey)
}

let mostRecentSearchTimestampKey = "mostRecentSearchTimestamp"
func setMostRecentSearchTimestamp() {
    let timestamp = NSDate().timeIntervalSince1970
    let timestampAsDouble = timestamp.advancedBy(0)
    NSUserDefaults.standardUserDefaults().setDouble(timestampAsDouble, forKey: mostRecentSearchTimestampKey)
    NSUserDefaults.standardUserDefaults().synchronize()
}
func getMostRecentSearchTimestamp() -> NSDate? {
    let timestampAsDouble = NSUserDefaults.standardUserDefaults().doubleForKey(mostRecentSearchTimestampKey)
    let timestamp = NSDate(timeIntervalSince1970: timestampAsDouble)
    return timestamp
}