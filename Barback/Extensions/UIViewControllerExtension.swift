//
//  BarbackViewController.swift
//  Barback
//
//  Created by Justin Duke on 6/25/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func runCoachMarks(coachMarks: [AnyObject]) {
        
        let userDefaultsKey = "coachMarksFor" + (((coachMarks[0] as NSDictionary)["caption"] as NSString).componentsSeparatedByString(" ")[0] as NSString)
        let haveCoachMarksBeenShown = NSUserDefaults.standardUserDefaults().boolForKey(userDefaultsKey)
        
        if (!haveCoachMarksBeenShown) {
            
            let coachMarksView = WSCoachMarksView(frame: view.bounds, coachMarks: coachMarks)
            coachMarksView.lblCaption.font = UIFont(name: UIFont.primaryFont(), size: 20)
            view.addSubview(coachMarksView)
            coachMarksView.start()
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: userDefaultsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func styleController() {
        navigationController?.navigationBar.translucent = false
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = Color.Dark.toUIColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: 20 as CGFloat)!]
        
        if (tabBarController != nil) {
            tabBarController?.tabBar.translucent = false
            tabBarController?.tabBar.barTintColor = Color.Dark.toUIColor()
            tabBarController?.tabBar.tintColor = Color.Tint.toUIColor()
        }
        
        view.backgroundColor = Color.Dark.toUIColor()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: 16)!], forState: UIControlState.Normal)
    }

}