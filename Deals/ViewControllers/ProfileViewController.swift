//
//  ProfileViewController.swift
//  Deals
//
//  Created by qbuser on 21/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookCore
import FacebookLogin
import AlamofireImage
import SVProgressHUD

class ProfileViewController: BaseViewController, GIDSignInUIDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var loginViewContent: UIView!
    @IBOutlet weak var profileTitleContentView: UIView!
    
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageBackground: UIView!
    @IBOutlet weak var profileContentView: UIView!
    @IBOutlet weak var purchaseHistoryCollectionView: UICollectionView!
    
    @IBOutlet weak var profileInfoView: UIView!
    @IBOutlet weak var favouritesItemsCountLabel: UILabel!

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var purchaseHistoryView: UIView!
    @IBOutlet weak var feedbackContentView: UIView!
    @IBOutlet weak var faqContentView: UIView!
    @IBOutlet weak var favouritesContentView: UIView!
    @IBOutlet weak var privacyContentView: UIView!

    @IBOutlet weak var numberOfPurchases: UILabel!
    var userProfile : UserProfile?
    
    override func viewDidLoad() {
        analyticsScreenName = "Profile View"

        super.viewDidLoad()

        profileImageBackground.layer.borderWidth = 2.0
        profileImageBackground.layer.borderColor = UIColor(displayP3Red: 41.0/255.0, green: 204.0/255.0, blue: 150.0/255.0, alpha: 1).cgColor
        profileInfoView.roundCorners([.bottomLeft, .bottomRight], radius: view.frame.size.width/2.5)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedIn(notification:)), name: NSNotification.Name("userLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userProfileUpdatedNotification(notification:)), name: Notification.Name("userProfileUpdated"), object: nil)
        
        if let _ = User.getProfile() {
            self.profileContentView.isHidden = false
            self.loginViewContent.isHidden = true
            self.fetchUserProfileAndUpdateView()
            analyticsScreenName = "Profile View"

            displayProfileData()
        } else {
            self.profileContentView.isHidden = true
            self.loginViewContent.isHidden = false
            analyticsScreenName = "Login View"

        }
        
        let purchaseHistoryCellNib = UINib(nibName: "PurchaseDealsCollectionViewCell", bundle: nil)
        self.purchaseHistoryCollectionView.register(purchaseHistoryCellNib, forCellWithReuseIdentifier: "PurchaseDealsCollectionViewCell")
        self.decorateViewElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func decorateProfileMenuListItem(decorationView : UIView) {
        decorationView.layer.cornerRadius = 6.0
        decorationView.layer.shadowColor = Constants.blackDarkColor.cgColor
        decorationView.layer.shadowOpacity = 0.14
        decorationView.layer.shadowOffset = CGSize.zero
        decorationView.clipsToBounds = false
    }
    
    func decorateViewElements() {
        self.decorateProfileMenuListItem(decorationView: self.feedbackContentView)
        self.decorateProfileMenuListItem(decorationView: self.faqContentView)
        self.decorateProfileMenuListItem(decorationView: self.favouritesContentView)
        decorateProfileMenuListItem(decorationView: privacyContentView)
    }
    
    @IBAction func logutButtonClicked(_ sender: Any) {
        let logoutAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive) { (action) in
            UserProfile.deleteProfile()
            self.profileContentView.isHidden = true
            self.loginViewContent.isHidden = false
            
            NotificationCenter.default.post(name: NSNotification.Name("userLoggedOut"), object: nil)

        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
        let logoutActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        logoutActionSheet.addAction(logoutAction)
        logoutActionSheet.addAction(cancelAction)
        
        self.present(logoutActionSheet, animated: true, completion: nil)
        
    }
    func displayProfileData() {
        if let profileData = self.userProfile {
            self.profileContentView.isHidden = false
            self.loginViewContent.isHidden = true
            if let profileImageUrl = profileData.photo {
                self.profileImageView.af_setImage(withURL: URL(string: profileImageUrl)!)
            }
            if let firstName = profileData.firstName {
                self.fullNameLabel.text = firstName
            }
            if let lastName = profileData.lastName {
                if let firstName = profileData.firstName {
                    self.fullNameLabel.text = firstName + " " + lastName
                } else {
                    self.fullNameLabel.text = lastName
                }
            }
            if let phoneNumber = profileData.phoneNumber {
                phoneNumberButton.setTitle(phoneNumber, for: .normal)
            }
            if let email = profileData.email {
                self.emailLabel.text = email
            }
            self.favouritesItemsCountLabel.text = "\(profileData.wishList!.count)"
            if profileData.purchases!.count > 0 {
                purchaseHistoryView.isHidden = false
                self.numberOfPurchases.text = "View All (\(profileData.purchases!.count))"
                self.purchaseHistoryCollectionView.reloadData()
            } else {
                purchaseHistoryView.isHidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func userLoggedIn(notification : Notification) {
        if let userProfile = notification.object as? [String : Any] {
            self.userProfile = UserProfile.userProfileWithProperties(properties: userProfile)
            self.displayProfileData()
        } else {
            self.fetchUserProfileAndUpdateView()
        }
    }
    
    @objc func userProfileUpdatedNotification(notification : Notification) {
        self.fetchUserProfileAndUpdateView()
    }
    
    func fetchUserProfileAndUpdateView() {
        let userProfileFetchHeader = ["Authorization" : "Token \(User.getProfile()!.token!)"]
        BaseWebservice.performRequest(function: WebserviceFunction.fetchUserProfile, requestMethod: .get, params: nil, headers: userProfileFetchHeader) { (response, error) in
            if let error = error {
                UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
            } else if let response = response as? [String : Any] {
                if response["status"] as? String == "success" {
                    if let userProfileProperties = response["user"] as? [String : Any] {
                        self.userProfile = UserProfile.userProfileWithProperties(properties: userProfileProperties)
                        self.userProfile?.token = User.getProfile()!.token!
                        self.userProfile?.saveToUserDefaults()
                        self.displayProfileData()
                    } else {
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                } else {
                    if response["detail"] as? String == "Invalid token." {
                        self.profileContentView.isHidden = true
                        self.loginViewContent.isHidden = false
                    } else {
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                }
            } else {
                UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
            }
        }
    }
    
    // MARK: - CollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let purchseDeals = self.userProfile?.purchases {
            return purchseDeals.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PurchaseDealsCollectionViewCell", for: indexPath) as! PurchaseDealsCollectionViewCell
        cell.customizeCell(deal: self.userProfile!.purchases![indexPath.row].deal!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let deal = self.userProfile!.purchases![indexPath.row].deal!
        performSegue(withIdentifier: "showDetailsView", sender: deal)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavouritesList" {
            let favouritesListViewController = segue.destination as! FavouritesListViewController
            favouritesListViewController.favourites = self.userProfile!.wishList
        } else if segue.identifier == "showPurchasesList" {
            let purchasesListViewController = segue.destination as! PurchasesListViewController
            purchasesListViewController.purchasesList = self.userProfile!.purchases
        } else if segue.identifier == "showDetailsView" {
            let detailsView = segue.destination as! DealDetailsViewController
            if let deal = sender as? Deal {
                detailsView.deal = deal
            }
        } else if segue.identifier == "showTerms" {
            let webView = segue.destination as! TermsViewController
            webView.itemTitle = "Terms and Conditions"
            webView.itemFileName = "dollordeals_terms"
        } else if segue.identifier == "showPrivacy" {
            let webView = segue.destination as! TermsViewController
            webView.itemTitle = "Privacy Policy"
            webView.itemFileName = "dollor_deals_privacy"
        } else if segue.identifier == "showPhoneInput" {
            let phoneInputView = segue.destination as! PhoneNumberInputViewController
            if let profileData = self.userProfile {
                phoneInputView.phoneNumberChangeActionBlock = {
                    if let user = User.getProfile() {
                        if let phoneNumber = user.phoneNumber {
                            self.phoneNumberButton.setTitle(phoneNumber, for: .normal)
                        }
                    }
                }
            }
        }
    }

    // MARK: - IBAction Methdods

    @IBAction func loginWithGoogleButtonClicked(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func loginWithFBButtonClicked(_ sender: Any) {
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
