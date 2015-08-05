//
//  LoginViewController.swift
//  Barback
//
//  Created by Justin Duke on 4/22/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//


import Foundation
import UIKit

class AppLoginViewController: UIViewController {

    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var twitterLoginButton: UIButton!

    @IBOutlet weak var loginExplanationLabel: EmptyStateLabel!

    override func viewDidLoad() {
        styleController()
        view.backgroundColor = Color.Background.toUIColor()
        loginExplanationLabel.text =
            "Hey!  Please login to start adding favorite recipes, notes, and more."
        twitterLoginButton.setTitle("Sign in with Twitter", forState: .Normal)
        facebookLoginButton.setTitle("Sign in with Facebook", forState: .Normal)
        twitterLoginButton.addTarget(self, action: "loginWithTwitter",
            forControlEvents: .TouchUpInside)
    }

}