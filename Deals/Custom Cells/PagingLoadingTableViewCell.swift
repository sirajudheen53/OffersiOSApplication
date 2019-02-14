//
//  PagingLoadingTableViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 14/02/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit

class PagingLoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
