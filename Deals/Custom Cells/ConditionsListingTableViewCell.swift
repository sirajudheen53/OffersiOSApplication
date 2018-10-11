//
//  ConditionsListingTableViewCell.swift
//  Test
//
//  Created by qbuser on 21/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class ConditionsListingTableViewCell: UITableViewCell {

    @IBOutlet weak var indexNumberLabel: UILabel!
    @IBOutlet weak var conditionTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
