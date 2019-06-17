//
//  FavouritesListViewController.swift
//  Deals
//
//  Created by Sirajudheen on 09/08/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreLocation

class FavouritesListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var favourites : [Deal]?
    
    @IBOutlet weak var noFavouritesImage: UIImageView!
    @IBOutlet weak var noFavouritesTitle1: UILabel!
    @IBOutlet weak var noFavouritesTitle2: UILabel!
    
    @IBOutlet weak var favouritesListingTableView: UITableView!
    override func viewDidLoad() {
        analyticsScreenName = "Favourites List View"

        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Favourites"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.favouritesListingTableView.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)

        let dealListingCellNib = UINib(nibName: "DealsListingTableViewCell", bundle: nil)
        self.favouritesListingTableView.register(dealListingCellNib, forCellReuseIdentifier: "dealListingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let favorites = favourites, favorites.count > 0 {
            favouritesListingTableView.isHidden = false
            noFavouritesImage.isHidden = true
            noFavouritesTitle1.isHidden = true
            noFavouritesTitle2.isHidden = true
        } else {
            favouritesListingTableView.isHidden = true
            noFavouritesImage.isHidden = false
            noFavouritesTitle1.isHidden = false
            noFavouritesTitle2.isHidden = false
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
        cell.enableLocationBlock = enableLocationBlock()
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

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
