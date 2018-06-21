//
//  HotDealCollectionViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 20/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class HotDealCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var offerPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func originalPriceAttributedText(value : String) -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font : Constants.regularFontWithSize(size: 14),
                          NSAttributedStringKey.foregroundColor : Constants.appliationGreyColor,
                          NSAttributedStringKey.strikethroughColor : Constants.appliationGreyColor,
                          NSAttributedStringKey.strikethroughStyle : 1] as [NSAttributedStringKey : Any]
        let requiredString = NSMutableAttributedString(string: value, attributes: attributes)
        return requiredString
    }
    
    
    func dealTitleAttributedText(title : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.8
        
        let attributes = [NSAttributedStringKey.font : Constants.compactTextRegulaFontWithSize(size: 12.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.dimGrey]
        let requiredString = NSAttributedString(string: title, attributes: attributes)
        return requiredString
    }
    
    func customizeCell(deal : Deal) {
        self.dealImageView.image = UIImage(named: "dummy_deal")
        self.vendorNameLabel.text = deal.vendor!.name!
        self.originalPriceLabel.attributedText = self.originalPriceAttributedText(value: "\(deal.originalPrice!)")
        self.offerPriceLabel.text = "\(deal.dealPrice!)"
        self.distanceValueLabel.text = "2 kms away"
        self.descriptionLabel.attributedText = self.dealTitleAttributedText(title: deal.dealDescription!)
    }

}
