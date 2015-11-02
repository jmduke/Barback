//
//  CoachMarksViewDelegate.swift
//  Barback
//
//  Created by Justin Duke on 8/15/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation

@objc protocol CoachMarksViewDelegate {
    
    optional func coachMarksViewWillCleanUp(view: CoachMarksView)
    optional func coachMarksViewDidCleanUp(view: CoachMarksView)
    optional func coachMarksViewWillNavigateToIndex(view: CoachMarksView, index: Int)
    optional func coachMarksViewDidNavigateToIndex(view: CoachMarksView, index: Int)
    
}