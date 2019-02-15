//
//  ExploreViewController.swift
//  Test
//
//  Created by qbuser on 22/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class ExploreViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var availableDeals = [Deal]()
    var filterCategories = [FilterCategories]()
    let numberOfItemsInAPage = 10

    var currentPage : Int = 1
    var numberOfPages : Int = 1
    var isLoadingList : Bool = false
    var searchString = ""
    
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
//        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
//            self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
//        }
        self.navigationController?.navigationBar.isHidden = true
        let dealListingCellNib = UINib(nibName: "DealsListingTableViewCell", bundle: nil)
        self.dealsListingTableView.register(dealListingCellNib, forCellReuseIdentifier: "dealListingCell")
        
        self.searchBackgroundView.layer.cornerRadius = 8.0
        
        self.filterContentView.layer.cornerRadius = 24.0
        self.filterNumberLabel.layer.cornerRadius = 8.0
        self.filterNumberLabel.clipsToBounds = true
        self.filterNumberLabel.text = "\(self.filterCategories.count)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func categoriesSelected(_ notification: Notification) {
        let selectedCategories = notification.object as! [FilterCategories]
        self.filterCategories = selectedCategories
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            searchDealsFromServer(location: selectedLocation, searchString: searchString)
        }
    }
    
    // MARK: - TextField Delegates

    @IBAction func textFieldChanged(_ sender: UITextField) {
        if let currentText = searchTextField.text {
            searchString = currentText
            numberOfPages = 1
            if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
                searchDealsFromServer(location: selectedLocation, searchString: searchString)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func searchDealsWithTerm(term : String, deals : [Deal]) -> [Deal] {
        if term.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
            return deals
        } else {
            return deals.filter {(deal) -> Bool in
                if deal.category!.name!.lowercased().contains(term.lowercased()) ||
                    deal.title.lowercased().contains(term.lowercased()) ||
                    deal.vendor!.name!.lowercased().contains(term.lowercased()) ||
                    deal.dealDescription.lowercased().contains(term.lowercased()) {
                    return true
                } else {
                    return false
                }
            }
        }
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
            self.searchDealsFromServer(location: selectedLocation, searchString: searchString)
        }
    }
    
    @objc func userLoggedOut(notification : Notification) {
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            self.searchDealsFromServer(location: selectedLocation, searchString: searchString)
        }
    }
    
    
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfCells = availableDeals.count
        if availableDeals.count == (numberOfPages-1) * numberOfItemsInAPage {
            return numberOfCells + 1
        } else {
            return numberOfCells
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row == availableDeals.count && availableDeals.count > 0{
            let pagingLoadingCell = tableView.dequeueReusableCell(withIdentifier: "pagingLoadingCell", for: indexPath) as! PagingLoadingTableViewCell
            pagingLoadingCell.activityIndicator.startAnimating()
            cell = pagingLoadingCell
            
            if !isLoadingList {
                currentPage += 1
                if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
                    searchDealsFromServer(location: selectedLocation, searchString: searchString)
                }
            }
            cell = pagingLoadingCell
        } else if availableDeals.count > 0 {
            let dealListingCell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell
            dealListingCell.customizeCell(deal: availableDeals[indexPath.row])
            dealListingCell.selectionStyle = .none
            cell = dealListingCell
        }
        
     
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    
    func searchDealsFromServer(location : String, searchString : String) {
        guard !isLoadingList else {
            return
        }
        
        isLoadingList = true
        
        var tokenHeader = [String : String]()
        if let token = User.getProfile()?.token {
            tokenHeader = ["Authorization" : "Token \(token)"]
        }
        BaseWebservice.performRequest(function: WebserviceFunction.search, requestMethod: .get, params: ["location" : location as AnyObject, "page" : currentPage as AnyObject, "search" : searchString as AnyObject, "category" : categoriesTitleList as AnyObject], headers: tokenHeader) { (response, error) in
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
                            
                            if let allDeals = allDealsProperties["deals"] as? [[String : Any]] {
                                self.availableDeals = Deal.dealObjectsFromProperties(properties: allDeals)
                            }
                            if self.availableDeals.count == 0{
                                self.noDealsContentView.isHidden = false
                                self.dealsListingTableView.isHidden = true
                            } else {
                                self.noDealsContentView.isHidden = true
                                self.dealsListingTableView.isHidden = false
                            }

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

}
