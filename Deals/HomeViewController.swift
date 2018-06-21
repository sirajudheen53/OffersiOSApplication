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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate, CLLocationManagerDelegate {

    var availableDeals : [Deal]?
    let locationManager = CLLocationManager()

    @IBOutlet weak var test: UIView!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var landmarkValueLabel: UILabel!
    
    @IBOutlet weak var locationSelectionView: UIView!
    @IBOutlet weak var dealsListingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        self.title = "Home"
    
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
        
        let hotDealsListingCellNib = UINib(nibName: "HotDealTableViewCell", bundle: nil)
        self.dealsListingTableView.register(hotDealsListingCellNib, forCellReuseIdentifier: "hotDealsListingCell")
        
        self.getUserLocationAndUpdateUI()
        self.fetchAllDealsFromServerAndUpdateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // MARK: - Location Manager Delegate Methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.getAddressFromLatLon(lat: locValue.latitude, withLongitude: locValue.longitude)
    }
    
    // MARK: - IBAction Methods

    @IBAction func getUserLocationButtonClicked(_ sender: Any) {
        self.getUserLocationAndUpdateUI()
    }
    
    
    // MARK: - Private Methods
    
    @objc func handleSelectLocationViewTap(sender: UITapGestureRecognizer? = nil) {
        
    }
    
    func getUserLocationAndUpdateUI() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            self.locationNameLabel.attributedText = self.locationAddressValueAttributedText(address: "Lulu Cyber Tower 2")
            self.landmarkValueLabel.attributedText = self.locationLandmarkValueAttributedText(address: "Plot 2, Infopark")
        }
    }
    
    func getAddressFromLatLon(lat: Double, withLongitude long: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = long
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if let locality = pm.locality {
                        self.locationNameLabel.attributedText = self.locationAddressValueAttributedText(address: locality)
                    }
                    if let sublocality = pm.subLocality {
                        self.landmarkValueLabel.attributedText = self.locationLandmarkValueAttributedText(address: sublocality)
                    }
                }
        })
        
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
        let cell : UITableViewCell
        if indexPath.row == 0 {
           let hotDealTableViewCell = tableView.dequeueReusableCell(withIdentifier: "hotDealsListingCell", for: indexPath) as! HotDealTableViewCell;
            hotDealTableViewCell.customizeCell(hotDeals: availableDeals!)
            cell = hotDealTableViewCell
        } else {
            let dealListingCell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath) as! DealsListingTableViewCell;
            dealListingCell.customizeCell(deal: availableDeals![indexPath.row])
            cell = dealListingCell
        }
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
