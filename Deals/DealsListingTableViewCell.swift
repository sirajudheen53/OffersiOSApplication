//
//  DealsListingTableViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 17/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class DealsListingTableViewCell: UITableViewCell {

    @IBOutlet weak var originalPriceValueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var offerPriceValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func customizeCell(deal : Deal) {
        if let originalPrice = deal.originalPrice {
            self.originalPriceValueLabel.text = "\(originalPrice)"
        } else {
            self.originalPriceValueLabel.text = "-"
        }
        if let title = deal.title {
            self.titleLabel.text = title
        } else {
            self.titleLabel.text = "-"
        }
        if let vendorName = deal.vendor?.name {
            self.vendorNameLabel.text = vendorName
        } else {
            self.vendorNameLabel.text = "-"
        }
        if let offerPrice = deal.dealPrice {
            self.offerPriceValueLabel.text = "\(offerPrice)"
        } else {
            self.offerPriceValueLabel.text = "-"
        }
    }

}
