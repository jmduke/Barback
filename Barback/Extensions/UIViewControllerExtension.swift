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
        
        let caption = (coachMarks[0] as! NSDictionary)["caption"] as! NSString
        let prefix: AnyObject = caption.componentsSeparatedByString(" ")[0]
        let userDefaultsKey = "coachMarksFor\(prefix)"
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
        navigationController?.styleController()
        
        if (tabBarController != nil) {
            tabBarController?.tabBar.translucent = false
            tabBarController?.tabBar.barTintColor = Color.Dark.toUIColor()
            tabBarController?.tabBar.tintColor = Color.Tint.toUIColor()
        }
        
        view.backgroundColor = Color.Dark.toUIColor()
    }

}

extension UINavigationController {
    override func styleController() {
        navigationBar.translucent = false
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = Color.Dark.toUIColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: 20 as CGFloat)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: 16)!], forState: UIControlState.Normal)
    }
}