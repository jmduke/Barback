//
//  BarbackViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/25/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func runCoachMarks(coachMarks: AnyObject[]) {
        
        let userDefaultsKey = "coachMarksFor" + (((coachMarks[0] as NSDictionary)["caption"] as NSString).componentsSeparatedByString(" ")[0] as NSString)
        let haveCoachMarksBeenShown = NSUserDefaults.standardUserDefaults().boolForKey(userDefaultsKey)
        
        if !haveCoachMarksBeenShown {
            let coachMarksView = WSCoachMarksView(frame: self.view.bounds, coachMarks: coachMarks)
            coachMarksView.lblCaption.font = UIFont(name: "Futura-Medium", size: 20)
            self.view.addSubview(coachMarksView)
            coachMarksView.start()
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: userDefaultsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

}