//
//  UIWebViewController.swift
//  Barback
//
//  Created by Justin Duke on 12/16/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class UIWebViewController: UINavigationController {
    
    init(url: NSURL, title: String, cancelSelector: String, parent: UIViewController) {
        
        let request = NSURLRequest(URL: url)
        let webView = UIWebView(frame: parent.navigationController!.view.frame)
        webView.scalesPageToFit = true
        webView.loadRequest(request)
        
        let controller = UIViewController()
        controller.view.addSubview(webView)
        
        super.init(rootViewController: controller)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: parent, action: Selector(cancelSelector))
        
        controller.navigationItem.title = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleController()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}