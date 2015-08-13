//
//  Shareable.swift
//  Barback
//
//  Created by Justin Duke on 8/12/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation

protocol Shareable {
 
    func shareableContent() -> [AnyObject]

}

extension UIViewController {
    
    func makeContentShareable() {
        if !(self is Shareable) {
            return
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareContent")
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    func shareContent() {
        if !(self is Shareable) {
            return
        }
        let activities = (self as! Shareable).shareableContent()
        let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        navigationController?.presentViewController(controller, animated: true, completion: nil)
        
        // Needed to play nice with iPad views.
        if (controller.respondsToSelector("popoverPresentationController")) {
            let presentationController = controller.popoverPresentationController
            let shareButton = self.navigationItem.rightBarButtonItem
            presentationController?.barButtonItem = shareButton
        }
    }
}