//
//  HomeViewController.swift
//  Test
//
//  Created by qbuser on 16/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import GoogleSignIn

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate {

    var availableDeals : [Deal]?
    
    @IBOutlet weak var dealsListingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        self.title = "Home"
    
        self.fetchAllDealsFromServerAndUpdateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsView" {
            if let detailsView = segue.destination as? DealDetailsViewController {
                detailsView.deal = sender as? Deal
            }
        }
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let availableDeals = self.availableDeals {
            return availableDeals.count;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell;
        cell.customizeCell(deal: availableDeals![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailsView", sender: self.availableDeals![indexPath.row])
    }
    
    // MARK: - Private Methods
    
    func fetchAllDealsFromServerAndUpdateUI() {
        BaseWebservice.performRequest(function: WebserviceFunction.fetchDealsList, requestMethod: .get, params: nil, headers: nil) { (response, error) in
            if let response = response as? [String : Any] {
                if let status = response["status"] as? String {
                    if status=="success" {
                        if let dealsProperties = response["data"] as? [[String : Any]] {
                            self.availableDeals = Deal.dealObjectsFromProperties(properties: dealsProperties)
                            self.dealsListingTableView.reloadData()
                        } else {
                            //Handle Error condition
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
