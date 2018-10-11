//
//  ExploreFilterViewController.swift
//  Deals
//
//  Created by Sirajudheen on 17/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class ExploreFilterViewController: UIViewController {

    var selectedFilters = [FilterCategories]()
    var exploreViewController : ExploreViewController?
    
    @IBOutlet weak var restaurentCategoryButton: UIButton!
    @IBOutlet weak var travelCategoryButton: UIButton!
    @IBOutlet weak var healthCategoryButton: UIButton!
    @IBOutlet weak var beautyCategoryButton: UIButton!
    @IBOutlet weak var carcareCategoryButton: UIButton!
    @IBOutlet weak var retailCategoryButton: UIButton!
    @IBOutlet weak var entertainmentCategoryButton: UIButton!
    @IBOutlet weak var servicesCategoryButton: UIButton!
    
    
    
    @IBOutlet weak var doneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setInitialCategoryTileImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setInitialCategoryTileImages() {
        restaurentCategoryButton.setBackgroundImage(UIImage(named: "restaurent")?.noir, for: UIControlState.normal)
        travelCategoryButton.setBackgroundImage(UIImage(named: "travel")?.noir, for: UIControlState.normal)
        healthCategoryButton.setBackgroundImage(UIImage(named: "health")?.noir, for: UIControlState.normal)
        beautyCategoryButton.setBackgroundImage(UIImage(named: "beauty")?.noir, for: UIControlState.normal)
        carcareCategoryButton.setBackgroundImage(UIImage(named: "carcare")?.noir, for: UIControlState.normal)
        retailCategoryButton.setBackgroundImage(UIImage(named: "reatail")?.noir, for: UIControlState.normal)
        entertainmentCategoryButton.setBackgroundImage(UIImage(named: "entertainment")?.noir, for: UIControlState.normal)
        servicesCategoryButton.setBackgroundImage(UIImage(named: "services")?.noir, for: UIControlState.normal)

    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        self.exploreViewController?.filterCategories = self.selectedFilters
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "categoriesFilterSelected"), object: self.selectedFilters, userInfo: nil))
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func filterCategoryButtonClicked(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if let index = self.selectedFilters.index(of: FilterCategories.Restaurent) {
                self.selectedFilters.remove(at: index)
            } else {
                self.selectedFilters.append(FilterCategories.Restaurent)
            }
        case 1:
            if let index = self.selectedFilters.index(of: FilterCategories.Travel) {
                self.selectedFilters.remove(at: index)
            } else {
                self.selectedFilters.append(FilterCategories.Travel)
            }
        case 2:
            if let index = self.selectedFilters.index(of: FilterCategories.Health) {
                self.selectedFilters.remove(at: index)
            } else {
                self.selectedFilters.append(FilterCategories.Health)
            }
        case 3:
            if let index = self.selectedFilters.index(of: FilterCategories.Beauty) {
                self.selectedFilters.remove(at: index)
            } else {
                self.selectedFilters.append(FilterCategories.Beauty)
            }
        case 4:
            if let index = self.selectedFilters.index(of: FilterCategories.CarCare) {
                self.selectedFilters.remove(at: index)
            } else {
                self.selectedFilters.append(FilterCategories.CarCare)
            }
        case 5:
            if let index = self.selectedFilters.index(of: FilterCategories.Retail) {
                self.selectedFilters.remove(at: index)
            } else {
                self.selectedFilters.append(FilterCategories.Retail)
            }
        case 6:
            if let index = self.selectedFilters.index(of: FilterCategories.Entertainment) {
                self.selectedFilters.remove(at: index)
            } else {
                self.selectedFilters.append(FilterCategories.Entertainment)
            }
        case 7:
            if let index = self.selectedFilters.index(of: FilterCategories.Services) {
                self.selectedFilters.remove(at: index)
            } else {
                self.selectedFilters.append(FilterCategories.Services)
            }
        default:
            break
        }
    }
    

}
