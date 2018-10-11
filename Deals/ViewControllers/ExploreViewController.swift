//
//  ExploreViewController.swift
//  Test
//
//  Created by qbuser on 22/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var availableDeals : [Deal]?
    var filteredDeals : [Deal]?
    var filterCategories = [FilterCategories]()
    
    @IBOutlet weak var searchBackgroundView: UIView!
    @IBOutlet weak var dealsListingTableView: UITableView!
    @IBOutlet weak var filterContentView: UIView!
    @IBOutlet weak var filterNumberLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(categoriesSelected(_:)), name: Notification.Name(rawValue: "categoriesFilterSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedIn(notification:)), name: NSNotification.Name("userLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedOut(notification:)), name: NSNotification.Name("userLoggedOut"), object: nil)
        
        
        self.dealsListingTableView.contentInset = UIEdgeInsets(top: 5.0, left: 0, bottom: 0, right: 0)
        self.fetchAllDealsFromServerAndUpdateUI()
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
        }
        self.dealsListingTableView.reloadData()
    }
    
    // MARK: - TextField Delegates

    @IBAction func textFieldChanged(_ sender: UITextField) {
        let categoryFilteredDeals = self.selectedCategoryFilteredDeals()
        if let currentText = searchTextField.text {
            self.filteredDeals = self.searchDealsWithTerm(term: currentText, deals: categoryFilteredDeals)
        }
        self.dealsListingTableView.reloadData()
    }
    
    func searchDealsWithTerm(term : String, deals : [Deal]) -> [Deal] {
        if term.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
            return deals
        } else {
            return deals.filter {(deal) -> Bool in
                if deal.category!.name!.lowercased().contains(term.lowercased()) ||
                    deal.title!.lowercased().contains(term.lowercased()) ||
                    deal.vendor!.name!.lowercased().contains(term.lowercased()) ||
                    deal.dealDescription!.lowercased().contains(term.lowercased()) {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    func selectedCategoryFilteredDeals() -> [Deal] {
        let selectedCategoryNames = self.filterCategories.map { appropriateCategoryName(category: $0)}
        if self.filterCategories.count == 0 {
            return self.availableDeals!
        } else {
            return self.availableDeals!.filter {
                selectedCategoryNames.contains($0.category!.name!)
            }
        }
    }
    
    func appropriateCategoryName(category : FilterCategories) -> String {
        switch category {
        case .Restaurent:
            return "Food"
        case .Travel:
            return "Travel"
        case .Health:
            return "Person Care"
        case .Beauty:
            return "Beauty"
        case .CarCare:
            return "Automotive"
        case .Retail:
            return "Retail Store"
        case .Entertainment:
            return "Entertainment"
        case .Services:
            return "Services"
        default:
            return "Services"
        }
    }
    
    @objc func userLoggedIn(notification : Notification) {
        self.fetchAllDealsFromServerAndUpdateUI()
    }
    
    @objc func userLoggedOut(notification : Notification) {
        self.fetchAllDealsFromServerAndUpdateUI()
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dealListingCell.currentUserLocation = appDelegate.currentUserLocation
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

    func fetchAllDealsFromServerAndUpdateUI() {
        var tokenHeader = [String : String]()
        if let token = User.getProfile()?.token {
            tokenHeader = ["Authorization" : "Token \(token)"]
        }
        BaseWebservice.performRequest(function: WebserviceFunction.fetchDealsList, requestMethod: .get, params: nil, headers: tokenHeader) { (response, error) in
            if let response = response as? [String : Any] {
                if let status = response["status"] as? String {
                    if status=="success" {
                        if let allDealsProperties = response["data"] as? [String : Any] {
                            if let allDeals = allDealsProperties["deals"] as? [[String : Any]] {
                                print(allDeals)
                                self.availableDeals = Deal.dealObjectsFromProperties(properties: allDeals)
                                self.filteredDeals = self.availableDeals
                                self.searchUpdateUI()
                            } else {
                                //Handle Error condition
                            }
                        } else {
                            
                        }
                    } else {
                        //Handle Error condition
                    }
                } else {
                    //Handle Error condition
                }
            } else {
                //Handle Error condition
            }
            
        }
    }

}
