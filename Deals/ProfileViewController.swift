//
//  ProfileViewController.swift
//  Deals
//
//  Created by qbuser on 21/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import GoogleSignIn

class ProfileViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     
    */

    // MARK: - IBAction Methdods

    @IBAction func loginWithGoogleButtonClicked(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func loginWithFBButtonClicked(_ sender: Any) {
    }
    
    //MARK:Google SignIn Delegate
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    // Present a view that prompts the user to sign in with Google
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    // Dismiss the "Sign in with Google" view
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}
