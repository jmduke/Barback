//
//  ParseLocalCaches.swift
//  Barback
//
//  Created by Justin Duke on 4/16/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

var ingredientsForRecipes: [Recipe:[Ingredient]] = {
    var dict = [Recipe:[Ingredient]]()
    for ingredient in Ingredient.all() {
        if let previousList = dict[ingredient.recipe] {
            dict[ingredient.recipe] = previousList + [ingredient]
        } else {
            dict[ingredient.recipe] = [ingredient]
        }
    }
    return dict
    }()

var favoritedRecipes: [Recipe] = {
    Recipe.favorites()
    }()

var privateKeys: NSDictionary = {
    let keychain = NSBundle.mainBundle().pathForResource("PrivateKeys", ofType: "plist")
    return NSDictionary(contentsOfFile: keychain!)!
    }()

func isConnectedToInternet() -> Bool {
    let reachability = Reachability.reachabilityForInternetConnection()
    let networkStatus = reachability.currentReachabilityStatus()
    let notReachableStatus = 0
    return networkStatus.rawValue != notReachableStatus
}