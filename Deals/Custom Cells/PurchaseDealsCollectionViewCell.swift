//
//  PurchaseDealsCollectionViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 19/07/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import AlamofireImage
import AFDateHelper

class PurchaseDealsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var purchasedDateLabel: UILabel!
    @IBOutlet weak var purchasedPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 6.0
        self.clipsToBounds = true
    }
    
    func customizeCell(deal : Deal) {
        self.dealImageView.image = UIImage(named: "logo_small")
        dealImageView.contentMode = UIViewContentMode.center
        
        if let vendorName = deal.vendor?.name {
            self.vendorNameLabel.text = vendorName
        }
        if let purchasedDate = deal.purchasedDate {
            self.purchasedDateLabel.text = purchasedDate.toString()
        }
            self.purchasedPriceLabel.text = "Purchased for \(deal.dealPrice)"
            self.originalPriceLabel.text = "\(deal.originalPrice)"
        if let images = deal.images {
            self.dealImageView.af_setImage(withURL: URL(string: image_service_url + images.first!)!,
                                           placeholderImage: UIImage(named: "logo_small"),
                                           filter: nil,
                                           progress: nil,
                                           progressQueue: DispatchQueue.main,
                                           imageTransition: UIImageView.ImageTransition.noTransition,
                                           runImageTransitionIfCached: false) { (data) in
                                            self.dealImageView?.contentMode = UIViewContentMode.scaleAspectFill
            }
        }
    }

}
