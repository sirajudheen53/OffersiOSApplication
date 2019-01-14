//
//  HomeViewController.swift
//  Test
//
//  Created by qbuser on 16/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import GoogleSignIn
import CoreLocation
import SkeletonView
import SwiftMessages

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate, CLLocationManagerDelegate, SkeletonTableViewDataSource {

    var availableDeals : [Deal]?
    var hotDeals : [Deal]?
    let locationManager = CLLocationManager()

    @IBOutlet weak var test: UIView!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var noDealsContentView: UIView!
    
    @IBOutlet weak var locationSelectionView: UIView!
    @IBOutlet weak var dealsListingTableView: UITableView!

    var currentLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: NSNotification.Name(rawValue: "locationUpdated"), object: nil)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedIn(notification:)), name: NSNotification.Name("userLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedOut(notification:)), name: NSNotification.Name("userLoggedOut"), object: nil)

        let hotDealsListingCellNib = UINib(nibName: "HotDealTableViewCell", bundle: nil)
        self.dealsListingTableView.register(hotDealsListingCellNib, forCellReuseIdentifier: "hotDealsListingCell")
        
        let dealListingCellNib = UINib(nibName: "DealsListingTableViewCell", bundle: nil)
        self.dealsListingTableView.register(dealListingCellNib, forCellReuseIdentifier: "dealListingCell")
        
        let exploreCellNib = UINib(nibName: "HomeExploreTableViewCell", bundle: nil)
        self.dealsListingTableView.register(exploreCellNib, forCellReuseIdentifier: "exploreTableViewCell")
        
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            locationNameLabel.text = selectedLocation
           self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
        } else {
            self.performSegue(withIdentifier: "showLocationSelection", sender: nil)
        }
        
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // MARK: - Location Manager Delegate Methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        DispatchQueue.main.async {
            self.currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.currentUserLocation = self.currentLocation
            self.dealsListingTableView.reloadData()
        }
    }
    
    @objc func locationUpdated() {
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            hotDeals = nil
            availableDeals = nil
            dealsListingTableView.reloadData()
            locationNameLabel.text = selectedLocation
            self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
        }
    }
    
    // MARK: - IBAction Methods

    @IBAction func getUserLocationButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "showLocationSelection", sender: nil)
    }
    
    
    // MARK: - Private Methods
    
    @objc func userLoggedIn(notification : Notification) {
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
        }
    }
    
    @objc func userLoggedOut(notification : Notification) {
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
        }
    }
    
    func locationAddressValueAttributedText(address : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.right
        paragraphStyle.lineSpacing = 1.6
        
        let attributes = [NSAttributedStringKey.font : Constants.mediumFontWithSize(size: 13.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.blackDarkColor]
        let requiredString = NSAttributedString(string: address, attributes: attributes)
        return requiredString
    }
    
    func locationLandmarkValueAttributedText(address : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.right
        paragraphStyle.lineSpacing = 1.6
        
        let attributes = [NSAttributedStringKey.font : Constants.regularFontWithSize(size: 12.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.darkGrey]
        let requiredString = NSAttributedString(string: address, attributes: attributes)
        return requiredString
    }
    
    func exploreCategorySelectionBlock() -> ((_ exploreCategory : FilterCategories) -> ()) {
        return {(category) in
            let exploreNavigationController = self.tabBarController?.viewControllers![1] as! UINavigationController
            let exploreViewController = exploreNavigationController.viewControllers[0] as! ExploreViewController
            exploreViewController.filterCategories = [category]
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    
    func hotDealCellSelectionActionBlock() -> ((_ deal : Deal) -> ()) {
        return {(deal) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showDetailsView", sender: deal)
            }
        }
    }
    
    func makeFavoriteDealBlock(deal : Deal) -> (()->()) {
        if let serverToken = User.getProfile()?.token {
            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            return {() in
                let flag = deal.isFavourited ? "false" : "true"
                BaseWebservice.performRequest(function: .makeFavourite, requestMethod: .post, params: ["deal_id" : deal.dealId as AnyObject, "flag" : flag as AnyObject], headers: userProfileFetchHeader, onCompletion: { (response, error) in
                    if let error = error {
                        UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                    } else if let response = response as? [String : Any?] {
                        if response["status"] as? String == "success" {
                            deal.isFavourited = true
                            NotificationCenter.default.post(Notification.init(name: Notification.Name("userProfileUpdated")))
                        } else {
                            UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                        }
                    } else {
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                })
            }
        } else {
            return {() in
                self.performSegue(withIdentifier: "showLoginPopup", sender: deal)
            }
        }
    }
    
    func makeFavouriteActionBlock() -> ((_ deal : Deal)->()) {
        if let serverToken = User.getProfile()?.token {
            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            return {(deal) in
                let flag = deal.isFavourited ? "false" : "true"
                BaseWebservice.performRequest(function: .makeFavourite, requestMethod: .post, params: ["deal_id" : deal.dealId as AnyObject, "flag" : flag as AnyObject], headers: userProfileFetchHeader, onCompletion: { (response, error) in
                    if let error = error {
                        UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                    } else if let response = response as? [String : Any?] {
                        if response["status"] as? String == "success" {
                            deal.isFavourited = true
                            NotificationCenter.default.post(Notification.init(name: Notification.Name("userProfileUpdated")))
                        } else {
                            UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                        }
                    } else {
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                })
            }
        } else {
            //Handle Error for no token found
            return {(deal) in
                self.performSegue(withIdentifier: "showLoginPopup", sender: deal)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsView" {
            if let detailsView = segue.destination as? DealDetailsViewController {
                detailsView.deal = sender as? Deal
            }
        } else if segue.identifier == "showLoginPopup" {
            if let popupView = segue.destination as? PopupViewController {
                if let deal = sender as? Deal {
                    popupView.actionBlock = self.makeFavoriteDealBlock(deal: deal)
                }
            }
        }
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let availableDeals = self.availableDeals {
            return availableDeals.count;
        } else {
            return 10;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if indexPath.row == 0 {
            let homeTitleCell = tableView.dequeueReusableCell(withIdentifier: "HomeTitleCell", for: indexPath)
            cell = homeTitleCell
        } else if indexPath.row == 1 {
           let hotDealTableViewCell = tableView.dequeueReusableCell(withIdentifier: "hotDealsListingCell", for: indexPath) as! HotDealTableViewCell;
            if let availableDeals = self.availableDeals {
                hotDealTableViewCell.currentUserLocation = self.currentLocation
                hotDealTableViewCell.customizeCell(hotDeals: availableDeals)
                hotDealTableViewCell.makeFavouriteActionBlock = self.makeFavouriteActionBlock()
                hotDealTableViewCell.hotDealsCellSelectionActionBlock = self.hotDealCellSelectionActionBlock()
            } else {
                hotDealTableViewCell.hotDealsListingCollectionView.reloadData()
            }
            
           cell = hotDealTableViewCell
        } else if indexPath.row == 2 {
            let dealNearbyTitleCell = tableView.dequeueReusableCell(withIdentifier: "dealsNearbyTitleCell", for: indexPath)
            cell = dealNearbyTitleCell
        } else if indexPath.row == 7 {
            let exploreTitleCell = tableView.dequeueReusableCell(withIdentifier: "expoloreTitleCell", for: indexPath)
            cell = exploreTitleCell
        } else if indexPath.row == 8 {
            let exploreCell = tableView.dequeueReusableCell(withIdentifier: "exploreTableViewCell", for: indexPath) as! HomeExploreTableViewCell
            exploreCell.exploreCategorySelectionBlock = self.exploreCategorySelectionBlock()
            cell = exploreCell
        } else {
            let dealListingCell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell;
            if let availableDeals = self.availableDeals {
                dealListingCell.currentUserLocation = self.currentLocation
                dealListingCell.customizeCell(deal: availableDeals[indexPath.row])
                dealListingCell.makeFavouriteActionBlock = self.makeFavouriteActionBlock()
            } else {
                dealListingCell.showLoadingAnimation()
            }
            
            cell = dealListingCell
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        if indexPath.row == 0 {
            height = 50
        } else if indexPath.row == 1 {
            height = 358
        } else if indexPath.row == 2 {
            height = 60
        } else if indexPath.row == 7{
            height = 60
        } else if indexPath.row == 8{
            height = 130.0
        } else  {
            height = 144.0
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showDetailsView", sender: self.availableDeals![indexPath.row])
        }
    }
    
    // MARK: - Private Methods
    
    func parseAllDealsResponseAndReloadView(allDealsResponse : [String : Any]) {
        if let hotDealsResponse = allDealsResponse["deals"] as? [[String : Any]] {
            hotDeals = Deal.dealObjectsFromProperties(properties: hotDealsResponse)
        }
        
        if let allDeals = allDealsResponse["deals"] as? [[String : Any]] {
            self.availableDeals = Deal.dealObjectsFromProperties(properties: allDeals)
            var favourites = [Deal]()
            var purchases = [Deal]()
            if let allFavoritedDeals = allDealsResponse["wishlist"] as? [[String : Any]] {
                favourites = Deal.dealObjectsFromProperties(properties: allFavoritedDeals)
            }
            if let allPurchased = allDealsResponse["purchases"] as? [[String : Any]] {
                for dealProperty in allPurchased {
                    if let singleDeal = dealProperty["deal"] as? [String : Any] {
                        let deal = Deal.dealObjectFromProperty(property: singleDeal)
                        if let purchaseDate = dealProperty["purchase_date"] as? Double {
                            deal.purchasedDate = Date(timeIntervalSince1970: purchaseDate)
                        }
                        if let purchaseExpiry = dealProperty["expiry_date"] as? Double {
                            deal.purchaseExpiry = Date(timeIntervalSince1970: purchaseExpiry)
                        }
                        if let code = dealProperty["code"] as? String {
                            deal.purchaseCode = code
                        }
                        if let isRedeemed = dealProperty["isRedeemed"] as? Bool {
                            deal.isRedeemed = isRedeemed
                        }
                        purchases.append(deal)
                    }
                }
            }
            _ = favourites.map({ (deal) -> Deal in
                let correspondingDeal = self.availableDeals?.filter({ $0.dealId == deal.dealId}).first
                correspondingDeal?.isFavourited = true
                return deal
            })
            
            _ = purchases.map({ (deal) -> Deal in
                if let correspondingDeal = self.availableDeals?.filter({ $0.dealId == deal.dealId}).first {
                    correspondingDeal.numberOfPurchases += 1
                    if let correspondingDealPurchseDate =  correspondingDeal.purchasedDate,
                        let dealPurchaseDate = deal.purchasedDate,
                        correspondingDealPurchseDate.timeIntervalSince1970 < dealPurchaseDate.timeIntervalSince1970 {
                        correspondingDeal.purchasedDate = dealPurchaseDate
                        correspondingDeal.purchaseCode = deal.purchaseCode
                        correspondingDeal.purchaseExpiry = deal.purchaseExpiry
                    } else if correspondingDeal.purchasedDate == nil {
                        correspondingDeal.purchasedDate = deal.purchasedDate
                        correspondingDeal.purchaseCode = deal.purchaseCode
                        correspondingDeal.purchaseExpiry = deal.purchaseExpiry
                    }
                }
                return deal
            })
            
            self.dealsListingTableView.reloadData()
            if self.availableDeals?.count == 0 {
                self.noDealsContentView.isHidden = false
                self.dealsListingTableView.isHidden = true
            } else {
                self.noDealsContentView.isHidden = true
                self.dealsListingTableView.isHidden = false
            }
        } else {
            //Handle Error condition
        }
    }
    
    func fetchAllDealsFromServerAndUpdateUI(location : String) {
        
        
        var tokenHeader = [String : String]()
        if let token = User.getProfile()?.token {
            tokenHeader = ["Authorization" : "Token \(token)"]
        }
        BaseWebservice.performRequest(function: WebserviceFunction.fetchDealsList, requestMethod: .get, params: ["location" : location as AnyObject], headers: tokenHeader) { (response, error) in
            if let error = error {
                UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                self.noDealsContentView.isHidden = false
                self.dealsListingTableView.isHidden = true
            } else if let response = response as? [String : Any] {
                if let status = response["status"] as? String {
                    if status=="success" {
                        if let allDealsProperties = response["data"] as? [String : Any] {
                            self.parseAllDealsResponseAndReloadView(allDealsResponse: allDealsProperties)
                        } else {
                            self.noDealsContentView.isHidden = false
                            self.dealsListingTableView.isHidden = true
                            UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                        }
                    } else {
                        self.noDealsContentView.isHidden = false
                        self.dealsListingTableView.isHidden = true
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                } else {
                    self.noDealsContentView.isHidden = false
                    self.dealsListingTableView.isHidden = true
                    UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                }
            } else {
                self.noDealsContentView.isHidden = false
                self.dealsListingTableView.isHidden = true
                UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
            }
        }
    }
    
    //Mark: - SkeletonTableViewDataSource
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "dealListingCell"
    }
}
