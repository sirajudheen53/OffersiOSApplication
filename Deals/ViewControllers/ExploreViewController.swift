//
//  ExploreViewController.swift
//  Test
//
//  Created by qbuser on 22/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class ExploreViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var availableDeals : [Deal]?
    var filteredDeals : [Deal]?
    var filterCategories = [FilterCategories]()
    
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
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
        }
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
        self.searchUpdateUI()
    }
    
    func searchUpdateUI() {
        self.filterNumberLabel.text = "\(self.filterCategories.count)"
        
        let categoryFilteredDeals = self.selectedCategoryFilteredDeals()
        if let currentText = searchTextField.text {
            self.filteredDeals = self.searchDealsWithTerm(term: currentText, deals: categoryFilteredDeals)
            if let filteredDeals = filteredDeals, filteredDeals.count == 0 {
                dealsListingTableView.isHidden = true
                noDealsContentView.isHidden = false
            } else {
                dealsListingTableView.isHidden = false
                noDealsContentView.isHidden = true
            }
        }
        self.dealsListingTableView.reloadData()
    }
    
    // MARK: - TextField Delegates

    @IBAction func textFieldChanged(_ sender: UITextField) {
        let categoryFilteredDeals = self.selectedCategoryFilteredDeals()
        if let currentText = searchTextField.text {
            self.filteredDeals = self.searchDealsWithTerm(term: currentText, deals: categoryFilteredDeals)
            if self.filteredDeals?.count == 0 {
                dealsListingTableView.isHidden = true
                noDealsContentView.isHidden = false
            } else {
                dealsListingTableView.isHidden = false
                noDealsContentView.isHidden = true
                self.dealsListingTableView.reloadData()
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
    
    func selectedCategoryFilteredDeals() -> [Deal] {
        let selectedCategoryNames = self.filterCategories.map { appropriateCategoryName(category: $0)}
        if self.filterCategories.count == 0, let avaialbleDeals = self.availableDeals {
            return avaialbleDeals
        } else if let avaialbleDeals = self.availableDeals  {
            return avaialbleDeals.filter {
                selectedCategoryNames.contains($0.category!.name!)
            }
        } else {
            return [Deal]()
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
            self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
        }
    }
    
    @objc func userLoggedOut(notification : Notification) {
        if let selectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            self.fetchAllDealsFromServerAndUpdateUI(location: selectedLocation)
        }
    }
    
    
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredDeals = self.filteredDeals {
            return filteredDeals.count;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dealListingCell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell
        dealListingCell.customizeCell(deal: filteredDeals![indexPath.row])
        dealListingCell.selectionStyle = .none
        return dealListingCell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showDealDetailView", sender: self.filteredDeals![indexPath.row])
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
    
    
    // MARK: - Private

    func parseAllDealsResponseAndReloadView(allDealsResponse : [String : Any]) {
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
            if let response = response as? [String : Any] {
                if let status = response["status"] as? String {
                    if status=="success" {
                        if let allDealsProperties = response["data"] as? [String : Any] {
                                self.parseAllDealsResponseAndReloadView(allDealsResponse: allDealsProperties)
                                self.filteredDeals = self.availableDeals
                                self.searchUpdateUI()
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
        }
    }

}
