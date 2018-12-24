//
//  LocationSelectionViewController.swift
//  Deals
//
//  Created by Sirajudheen on 15/12/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class LocationSelectionViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var trivandrumLocation: UIButton!
    @IBOutlet weak var cochiLocation: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentSelectedLocation = UserDefaults.standard.value(forKey: "SelectedLocation") as? String {
            if currentSelectedLocation == "Cochin" {
                cochiLocation.isSelected = true
                trivandrumLocation.isSelected = false
            } else {
                cochiLocation.isSelected = false
                trivandrumLocation.isSelected = true
            }
            
        } else {
            cochiLocation.isSelected = true
            trivandrumLocation.isSelected = false
            UserDefaults.standard.set("Cochin", forKey: "SelectedLocation")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func trivandrumSelected(_ sender: UIButton) {
        cochiLocation.isSelected = false
        trivandrumLocation.isSelected = true
        UserDefaults.standard.set("Trivandrum", forKey: "SelectedLocation")

    }
    @IBAction func cochiSelected(_ sender: UIButton) {
        cochiLocation.isSelected = true
        trivandrumLocation.isSelected = false
        UserDefaults.standard.set("Cochin", forKey: "SelectedLocation")

    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "locationUpdated")))
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
