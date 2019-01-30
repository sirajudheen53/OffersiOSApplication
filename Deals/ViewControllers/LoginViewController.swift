//
//  LoginViewController.swift
//  Test
//
//  Created by qbuser on 15/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: BaseViewController, GIDSignInUIDelegate {

    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        analyticsScreenName = "Login View"
        super.viewDidLoad()

        
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

