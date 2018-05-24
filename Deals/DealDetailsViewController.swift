//
//  DealDetailsViewController.swift
//  Test
//
//  Created by qbuser on 21/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class DealDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var conditionsView: UIView!
    @IBOutlet weak var offerDetailsView: UIView!
    @IBOutlet weak var offerTitleLabel: UILabel!
    
    let conditionsArray = ["1 Voucher Valid for 1 person only", "Print/ SMS/ In-App voucher can be used to avail the deal", "Prior reservation recommneded (Upon purchase, you will receive a voucher with the reservation number)", "Timings: 12:30 PM to 3:30 PM Monday to Friday", "Prices are inclusive of all tax and other service charges", "Food images are for representation purpose only", "Voucher codes in one transaction must be used in 1 visit. For seperate use, seperate transactions must be made"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Details"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func buyNowButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func optionsSegmentClicked(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            offerDetailsView.isHidden = false
            conditionsView.isHidden = true
        } else {
            conditionsView.isHidden = false
            offerDetailsView.isHidden = true
        }
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conditionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conditionsListCell", for: indexPath) as! ConditionsListingTableViewCell
        cell.conditionTextLabel.text = conditionsArray[indexPath.row]
        cell.indexNumberLabel.text = "\(indexPath.row+1)"
        return cell
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
