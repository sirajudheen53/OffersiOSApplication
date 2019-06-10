//
//  ExploreViewController.swift
//  Test
//
//  Created by qbuser on 22/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreLocation

class ExploreViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var availableDeals = [Deal]()
    var filterCategories = [FilterCategories]()
    let numberOfItemsInAPage = 10

    var nextPageToLoad : Int = 1
    var numberOfPages : Int = 1
    var isLoadingList : Bool = false
    var searchString = ""
    var lastLoadedSearchString = ""
    
    @IBOutlet weak var noDealsContentView: UIView!
    @IBOutlet weak var searchBackgroundView: UIView!
    @IBOutlet weak var dealsListingTableView: UITableView!
    @IBOutlet weak var filterContentView: UIView!
    @IBOutlet weak var filterNumberLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        analyticsScreenName = "Explore View"

        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(categoriesSelected(_:)), name: Notification.Name(rawValue: "categoriesFilterSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedIn(notification:)), name: NSNotification.Name("userLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedOut(notification:)), name: NSNotification.Name("userLoggedOut"), object: nil)
        
        
        self.dealsListingTableView.contentInset = UIEdgeInsets(top: 5.0, left: 0, bottom: 0, right: 0)

        
        self.navigationController?.navigationBar.isHidden = true
        let dealListingCellNib = UINib(nibName: "DealsListingTableViewCell", bundle: nil)
        self.dealsListingTableView.register(dealListingCellNib, forCellReuseIdentifier: "dealListingCell")
        
        self.searchBackgroundView.layer.cornerRadius = 8.0
        
        self.filterContentView.layer.cornerRadius = 24.0
        self.filterNumberLabel.layer.cornerRadius = 8.0
        self.filterNumberLabel.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.filterNumberLabel.text = "\(self.filterCategories.count)"
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String, filterCategories.count > 0 {
            numberOfPages = 1
            nextPageToLoad = 1
            searchDealsFromServer(location: selectedLocation, _searchString: searchString)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func categoriesSelected(_ notification: Notification) {
        let selectedCategories = notification.object as! [FilterCategories]
        self.filterCategories = selectedCategories
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            numberOfPages = 1
            nextPageToLoad = 1
            searchDealsFromServer(location: selectedLocation, _searchString: searchString)
        }
        self.filterNumberLabel.text = "\(self.filterCategories.count)"

    }
    
    // MARK: - TextField Delegates

    @IBAction func textFieldChanged(_ sender: UITextField) {
        if let currentText = searchTextField.text {
            searchString = currentText
            numberOfPages = 1
            nextPageToLoad = 1
            dealsListingTableView.reloadData()
            if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
                searchDealsFromServer(location: selectedLocation, _searchString: searchString)
            }
        } else {
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func appropriateCategoryName(category : FilterCategories) -> String {
        switch category {
        case .Restaurent:
            return "Restaurent"
        case .Travel:
            return "Travel"
        case .Health:
            return "Health"
        case .Beauty:
            return "Beauty"
        case .CarCare:
            return "Car Care"
        case .Retail:
            return "Retail"
        case .Entertainment:
            return "Entertainment"
        case .Services:
            return "Services"
        }
    }
    
    @objc func userLoggedIn(notification : Notification) {
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            self.searchDealsFromServer(location: selectedLocation, _searchString: searchString)
        }
    }
    
    @objc func userLoggedOut(notification : Notification) {
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            self.searchDealsFromServer(location: selectedLocation, _searchString: searchString)
        }
    }
    
    func enableLocationBlock() -> (()->()) {
        return { // initialise a pop up for using later
            let alertController = UIAlertController(title: "Dollar Deals", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
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
    
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfCells = availableDeals.count
        if availableDeals.count == (numberOfPages-1) * numberOfItemsInAPage && lastLoadedSearchString == searchString && availableDeals.count > 0 {
            return isLoadingList ? numberOfCells + 2 : numberOfCells + 1
        } else {
            return isLoadingList ? numberOfCells + 1 : numberOfCells
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        print("Explore index --- \(indexPath.row)")
        if isLoadingList && indexPath.row == 0 && availableDeals.count > 0 {
            let pagingLoadingCell = tableView.dequeueReusableCell(withIdentifier: "pagingLoadingCell", for: indexPath) as! PagingLoadingTableViewCell
            pagingLoadingCell.activityIndicator.startAnimating()
            cell = pagingLoadingCell
        } else if indexPath.row == availableDeals.count && availableDeals.count > 0{
            let pagingLoadingCell = tableView.dequeueReusableCell(withIdentifier: "pagingLoadingCell", for: indexPath) as! PagingLoadingTableViewCell
            pagingLoadingCell.activityIndicator.startAnimating()
            cell = pagingLoadingCell
            
            if !isLoadingList && lastLoadedSearchString == searchString {
                if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
                    self.nextPageToLoad += 1
                    searchDealsFromServer(location: selectedLocation, _searchString: searchString)
                }
            }
            cell = pagingLoadingCell
        } else if availableDeals.count > 0 {
            let dealListingCell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell
            dealListingCell.customizeCell(deal: availableDeals[indexPath.row])
            dealListingCell.selectionStyle = .none
            dealListingCell.enableLocationBlock = enableLocationBlock()
            cell = dealListingCell
        } else {
            cell = UITableViewCell()
        }
        
     
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoadingList && indexPath.row == 0 && availableDeals.count > 0 {
            return 44.0
        } else if indexPath.row == availableDeals.count && availableDeals.count > 0 {
            return 44.0
        }
        return 144.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.availableDeals.count else {
            return
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showDealDetailView", sender: self.availableDeals[indexPath.row])
        }
    }
    
 // MARK: - Navigation
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilterView" {
            let destinationViewController = segue.destination as! ExploreFilterViewController
            destinationViewController.exploreViewController = self
            destinationViewController.selectedFilters = self.filterCategories
        }
        else if segue.identifier == "showDealDetailView" {
            if let detailsView = segue.destination as? DealDetailsViewController {
                detailsView.deal = sender as? Deal
            }
        }
    }
    
    
    func searchDealsFromServer(location : String, _searchString : String) {
        isLoadingList = true
        
        var tokenHeader = [String : String]()
        if let token = User.getProfile()?.token {
            tokenHeader = ["Authorization" : "Token \(token)"]
        }
        
        var categories = [String]()
        for selectedCategory in filterCategories {
            categories.append(appropriateCategoryName(category: selectedCategory))
        }
        
        BaseWebservice.performRequest(function: WebserviceFunction.search, requestMethod: .get, params: ["location" : location as AnyObject, "page" : nextPageToLoad as AnyObject, "search" : _searchString as AnyObject, "category" : categories as AnyObject], headers: tokenHeader) { (response, error) in
            self.isLoadingList = false
            if let error = error {
                UIView.showWarningMessage(title: "Sorry !!!", message: error.localizedDescription)
                self.noDealsContentView.isHidden = false
                self.dealsListingTableView.isHidden = true
            } else if let response = response as? [String : Any] {
                if let status = response["status"] as? String {
                    if status=="success" {
                        if let allDealsProperties = response["data"] as? [String : Any] {
                            if let totalPages = allDealsProperties["total_pages"] as? Int {
                                self.numberOfPages = totalPages
                            }
                            if let allDeals = allDealsProperties["deals"] as? [[String : Any]] {
                                if self.nextPageToLoad == 1 && self.searchString == _searchString {
                                    self.availableDeals = Deal.dealObjectsFromProperties(properties: allDeals)
                                    self.dealsListingTableView.reloadData()
                                } else if self.lastLoadedSearchString == _searchString {
                                    self.availableDeals.append(contentsOf: Deal.dealObjectsFromProperties(properties: allDeals))
                                    self.dealsListingTableView.reloadData()
                                }
                            }

                            if self.availableDeals.count == 0 {
                                self.noDealsContentView.isHidden = false
                                self.dealsListingTableView.isHidden = true
                            } else {
                                self.noDealsContentView.isHidden = true
                                self.dealsListingTableView.isHidden = false
                            }

                            
                            self.lastLoadedSearchString = _searchString

                        } else {

                            self.noDealsContentView.isHidden = false
                            self.dealsListingTableView.isHidden = true
                            UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                            self.lastLoadedSearchString = _searchString

                        }
                    } else {
                        self.noDealsContentView.isHidden = false
                        self.dealsListingTableView.isHidden = true
                        UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                        self.lastLoadedSearchString = _searchString

                    }
                }  else if let message = response["message"] as? String {
                    self.noDealsContentView.isHidden = false
                    self.dealsListingTableView.isHidden = true
                    UIView.showWarningMessage(title: "Oops !", message: message)
                    self.lastLoadedSearchString = _searchString
                }  else {
                    self.noDealsContentView.isHidden = false
                    self.dealsListingTableView.isHidden = true
                    UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                    self.lastLoadedSearchString = _searchString

                }
            } else {
                self.noDealsContentView.isHidden = false
                self.dealsListingTableView.isHidden = true
                UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                self.lastLoadedSearchString = _searchString

            }
        }
    }

}
