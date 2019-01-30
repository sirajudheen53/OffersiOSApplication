//
//  PopupViewController.swift
//  Deals
//
//  Created by qbuser on 24/12/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookCore
import FacebookLogin
import SVProgressHUD
class PopupViewController: BaseViewController, GIDSignInUIDelegate {

    var actionBlock : (()->())?
    
    override func viewDidLoad() {
        analyticsScreenName = "Login Popup View"

        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedIn(notification:)), name: NSNotification.Name("userLoggedIn"), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backgroundButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func loginWithGoogleClicked(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func loginWithFBClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: {loginResult in
            switch loginResult {
            case .failed(let error):
                UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
            case .cancelled:
                print("User cancelled login.")
            case .success(_, _, let accessToken):
                SVProgressHUD.show()
                BaseWebservice.performRequest(function: WebserviceFunction.login, requestMethod: .post, params: ["id_token" : accessToken.authenticationToken as AnyObject, "provider" : "facebook" as AnyObject], headers: nil) { (response, error) in
                    SVProgressHUD.dismiss()
                    if let error = error {
                        UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                        
                    } else if let response = response as? [String : Any] {
                        if let status = response["status"] as? String {
                            if status == "success" {
                                if let userProperties = response["user"] as? [String : Any] {
                                    let userObject = User.userObjectWithProperties(properties: userProperties)
                                    userObject.saveToUserDefaults()
                                    NotificationCenter.default.post(name: NSNotification.Name("userLoggedIn"), object: userProperties)
                                } else {
                                    UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                                }
                            } else {
                                UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                            }
                        } else {
                            UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                        }
                    } else {
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                }            }
        })
    }
    
    @objc func userLoggedIn(notification : Notification) {
        if let actionBlock = actionBlock {
            actionBlock()
        }
        dismiss(animated: false, completion: nil)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
