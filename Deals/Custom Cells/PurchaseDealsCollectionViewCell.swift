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
        dealImageView.contentMode = UIView.ContentMode.center
        
        if let vendorName = deal.vendor?.name {
            self.vendorNameLabel.text = vendorName
        }
        if let purchasedDate = deal.purchasedDate {
            self.purchasedDateLabel.text = purchasedDate.toString(format: DateFormatType.custom("dd MMM yyy"))
        }
        
        if deal.isRedeemed {
            purchasedPriceLabel.text = "Coupon is redeemed"
            purchasedPriceLabel.textColor = Constants.mountainMedow
        } else if deal.purchaseExpiry < Date() {
            purchasedPriceLabel.text = "Coupon Expired"
            purchasedPriceLabel.textColor = Constants.redColor
        } else {
            let date2: Date = Date() // Same you did before with timeNow variable
            
            let calender:Calendar = Calendar.current
            let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date2, to: deal.purchaseExpiry)
            if let hour = components.hour, let minuites = components.minute {
                self.purchasedPriceLabel.text = "Expires in \(hour) h \(minuites) m"
                purchasedPriceLabel.textColor = UIColor(red: 248.0/255.0, green: 37.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            }
        }
        self.originalPriceLabel.text = "\(deal.currencySymbol) "+"\(deal.originalPrice)"
        if let images = deal.images {
            self.dealImageView.af_setImage(withURL: URL(string: image_service_url + images.first!)!,
                                           placeholderImage: UIImage(named: "logo_small"),
                                           filter: nil,
                                           progress: nil,
                                           progressQueue: DispatchQueue.main,
                                           imageTransition: UIImageView.ImageTransition.noTransition,
                                           runImageTransitionIfCached: false) { (data) in
                                            if let _ = data.result.value {
                                                self.dealImageView?.contentMode = UIView.ContentMode.scaleAspectFill
                                            }
            }
        }
    }

}
