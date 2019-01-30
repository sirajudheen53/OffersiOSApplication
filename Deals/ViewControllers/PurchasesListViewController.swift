//
//  PurchasesListViewController.swift
//  Deals
//
//  Created by Sirajudheen on 10/08/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class PurchasesListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var purchasesListTableView: UITableView!
    var purchasesList : [Purchase]?
    override func viewDidLoad() {
        analyticsScreenName = "Purchases View"

        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.title = "Purchases"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.purchasesListTableView.contentInset = UIEdgeInsetsMake(20.0, 0, 0, 0)
        let dealListingCellNib = UINib(nibName: "DealsListingTableViewCell", bundle: nil)
        self.purchasesListTableView.register(dealListingCellNib, forCellReuseIdentifier: "dealListingCell")    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsView" {
            if let detailsView = segue.destination as? DealDetailsViewController {
                detailsView.deal = sender as? Deal
            }
        }
     }
    
    // MARK: - TableView Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let purchases = purchasesList {
            return purchases.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell
        cell.customizeCell(deal: purchasesList![indexPath.row].deal!)
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailsView", sender: self.purchasesList![indexPath.row].deal)
    }
    
}
