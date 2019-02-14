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


class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate, SkeletonTableViewDataSource {

    var availableDeals = [Deal]()
    var hotDeals : [Deal]?

    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var noDealsContentView: UIView!
    
    @IBOutlet weak var locationSelectionView: UIView!
    @IBOutlet weak var dealsListingTableView: UITableView!
    
    let numberOfExtraCells = 5
    let numberOfItemsInAPage = 10

    var currentPage : Int = 1
    var numberOfPages : Int = 1
    var isLoadingList : Bool = false
    
    override func viewDidLoad() {
        analyticsScreenName = "Home View"

        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedIn(notification:)), name: NSNotification.Name("userLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedOut(notification:)), name: NSNotification.Name("userLoggedOut"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.detailsViewDismissed(notification:)), name: NSNotification.Name("detailsViewDismissed"), object: nil)

        let hotDealsListingCellNib = UINib(nibName: "HotDealTableViewCell", bundle: nil)
        self.dealsListingTableView.register(hotDealsListingCellNib, forCellReuseIdentifier: "hotDealsListingCell")
        
        let dealListingCellNib = UINib(nibName: "DealsListingTableViewCell", bundle: nil)
        self.dealsListingTableView.register(dealListingCellNib, forCellReuseIdentifier: "dealListingCell")
        
        let exploreCellNib = UINib(nibName: "HomeExploreTableViewCell", bundle: nil)
        self.dealsListingTableView.register(exploreCellNib, forCellReuseIdentifier: "exploreTableViewCell")
        
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            locationNameLabel.text = selectedLocation
           self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
        }
        
        self.navigationController?.navigationBar.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func enableLocationBlock() -> (()->()) {
        return { // initialise a pop up for using later
            let alertController = UIAlertController(title: "Dollor Deals", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                        
                    })
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            
            // check the permission status
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedAlways, .authorizedWhenInUse:
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.locationManager.startUpdatingLocation()
                }
            // get the user location
            case .notDetermined, .restricted, .denied:
                // redirect the users to settings
                self.present(alertController, animated: true, completion: nil)
            }}
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
    
    @objc func detailsViewDismissed(notification : Notification) {
        dealsListingTableView.reloadData()
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
        if availableDeals.count > 0 {
            let numberOfCells = availableDeals.count + numberOfExtraCells
            if availableDeals.count == (numberOfPages-1) * numberOfItemsInAPage {
                return numberOfCells + 1
            } else {
                return numberOfCells
            }
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
            if let hotDeals = self.hotDeals {
                hotDealTableViewCell.customizeCell(hotDeals: hotDeals)
                hotDealTableViewCell.makeFavouriteActionBlock = self.makeFavouriteActionBlock()
                hotDealTableViewCell.hotDealsCellSelectionActionBlock = self.hotDealCellSelectionActionBlock()
                hotDealTableViewCell.enableLocationBlock = enableLocationBlock()
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
        } else if indexPath.row == availableDeals.count + numberOfExtraCells {
            let pagingLoadingCell = tableView.dequeueReusableCell(withIdentifier: "pagingLoadingCell", for: indexPath) as! PagingLoadingTableViewCell
            pagingLoadingCell.activityIndicator.startAnimating()
            cell = pagingLoadingCell
            
            if !isLoadingList {
                currentPage += 1
                if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
                    self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
                }
            }
        } else {
            var index = 0
            if indexPath.row < 7 {
                index = indexPath.row - 3
            } else {
                index = indexPath.row - numberOfExtraCells
            }
            let dealListingCell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell;
            if availableDeals.count > 0 {
                    dealListingCell.customizeCell(deal: availableDeals[index])
                    dealListingCell.makeFavouriteActionBlock = self.makeFavouriteActionBlock()
                dealListingCell.enableLocationBlock = enableLocationBlock()

                    cell = dealListingCell
            } else {
                dealListingCell.showLoadingAnimation()
                cell = dealListingCell
            }
            
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
        } else if indexPath.row == availableDeals.count + numberOfExtraCells {
            height = 44.0
        } else  {
            height = 144.0
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2
            || indexPath.row == 7 || indexPath.row == availableDeals.count + numberOfExtraCells{
            return
        }
        DispatchQueue.main.async {
            var index = 0
            if indexPath.row < 7 {
                index = indexPath.row - 3
            } else {
                index = indexPath.row - self.numberOfExtraCells
            }
            self.performSegue(withIdentifier: "showDetailsView", sender: self.availableDeals[index])
        }
    }
    
    // MARK: - Private Methods
    
    func fetchAllDealsFromServerAndUpdateUI(location : String) { 
        guard !isLoadingList else {
            return
        }
        
        isLoadingList = true
        
        var tokenHeader = [String : String]()
        if let token = User.getProfile()?.token {
            tokenHeader = ["Authorization" : "Token \(token)"]
        }
        BaseWebservice.performRequest(function: WebserviceFunction.fetchDealsList, requestMethod: .get, params: ["location" : location as AnyObject, "page" : currentPage as AnyObject], headers: tokenHeader) { (response, error) in
            self.isLoadingList = false

            if let error = error {
                UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                self.noDealsContentView.isHidden = false
                self.dealsListingTableView.isHidden = true
            } else if let response = response as? [String : Any] {
                if let status = response["status"] as? String {
                    if status=="success" {
                        if let allDealsProperties = response["data"] as? [String : Any] {
                            if let totalPages = allDealsProperties["total_pages"] as? Int {
                                self.numberOfPages = totalPages
                            }
                            if let hotTodayProperties = allDealsProperties["hot_today"] as? [[String : Any]] {
                                self.hotDeals = Deal.dealObjectsFromProperties(properties: hotTodayProperties)
                            }
                            if let allDeals = allDealsProperties["deals"] as? [[String : Any]] {
                                self.availableDeals.append(contentsOf: Deal.dealObjectsFromProperties(properties: allDeals))
                            }
                            self.noDealsContentView.isHidden = true
                            self.dealsListingTableView.isHidden = false
                            self.dealsListingTableView.reloadData()
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
