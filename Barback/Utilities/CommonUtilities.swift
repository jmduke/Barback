//
//  CommonUtilities.swift
//  Barback
//
//  Created by Justin Duke on 12/7/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

func runningOnIPad() -> Bool {
    return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
}

func getRecipeDetailController(segue: UIStoryboardSegue?) -> RecipeDetailViewController {
    if runningOnIPad() {
        return segue!.destinationViewController.topViewController as! RecipeDetailViewController
    } else {
        return segue!.destinationViewController as! RecipeDetailViewController
    }
}

let externalUrl = NSURL(scheme: "http", host: "getbarback.com", path: "/")