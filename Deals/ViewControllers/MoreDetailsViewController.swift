//
//  MoreDetailsViewController.swift
//  Deals
//
//  Created by qbuser on 26/12/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class MoreDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var conditions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conditions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "condtionsCell", for: indexPath) as? ConditionsListingTableViewCell {
            cell.indexNumberLabel.text = "\(indexPath.row+1)."
            cell.conditionTextLabel.text = "\(conditions[indexPath.row])"
            return cell
        }
        return UITableViewCell()
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
