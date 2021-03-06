//
//  MoreDetailsViewController.swift
//  Deals
//
//  Created by qbuser on 26/12/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class MoreDetailsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var deal : Deal?
    
    override func viewDidLoad() {
        analyticsScreenName = "More Details View"

        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        headerView.backgroundColor = Constants.detailsHeader;
        let headerLablel = UILabel(frame: CGRect.init(x: 5, y: 0, width: tableView.frame.size.width, height: 30))
        headerLablel.font = Constants.boldProDisplayWithSize(size: 14)
        headerLablel.textColor = Constants.taupeyGrey
        headerLablel.text = section == 0 ? "Product Features" : "Terms And Conditions"
        headerView.addSubview(headerLablel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? deal!.features.count : deal!.conditons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        if let deal = deal {
            if indexPath.section == 0 {
                let feature = deal.features[indexPath.row]
                if feature.featureTitle == "" {
                    let listingCell = tableView.dequeueReusableCell(withIdentifier: "featureListingCell", for: indexPath) as! FeatureListingTableViewCell
                    listingCell.contentLabel?.text = feature.featureDescription
                    cell = listingCell
                } else {
                    let listingCellWithHeading = tableView.dequeueReusableCell(withIdentifier: "featuerListingWithHeaderCell", for: indexPath) as! FeatureListingWithHeadingTableViewCell
                    listingCellWithHeading.contentHeadingLabel.text = feature.featureTitle
                    listingCellWithHeading.contentLabel.text = feature.featureDescription
                    cell = listingCellWithHeading
                }
            } else {
                let conditionCell = tableView.dequeueReusableCell(withIdentifier: "condtionsCell", for: indexPath) as! ConditionsListingTableViewCell
                    conditionCell.indexNumberLabel.text = "\(indexPath.row+1)."
                    conditionCell.conditionTextLabel.text = "\(deal.conditons[indexPath.row])"
                cell = conditionCell
            }
        } else {
            cell = UITableViewCell()
        }
 
        return cell
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss(animated: false, completion: nil)
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
