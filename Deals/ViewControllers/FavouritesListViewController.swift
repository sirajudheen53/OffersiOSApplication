//
//  FavouritesListViewController.swift
//  Deals
//
//  Created by Sirajudheen on 09/08/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class FavouritesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var favourites : [Deal]?
    
    @IBOutlet weak var favouritesListingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Favourites"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.favouritesListingTableView.contentInset = UIEdgeInsetsMake(20.0, 0, 0, 0)

        let dealListingCellNib = UINib(nibName: "DealsListingTableViewCell", bundle: nil)
        self.favouritesListingTableView.register(dealListingCellNib, forCellReuseIdentifier: "dealListingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let favourites = favourites {
            return favourites.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell
        cell.customizeCell(deal: favourites![indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailsView", sender: self.favourites![indexPath.row])
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
}
