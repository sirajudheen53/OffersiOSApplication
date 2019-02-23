//
//  FeatureListingWithHeadingTableViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 23/02/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit

class FeatureListingWithHeadingTableViewCell: UITableViewCell {

    @IBOutlet weak var contentHeadingLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
