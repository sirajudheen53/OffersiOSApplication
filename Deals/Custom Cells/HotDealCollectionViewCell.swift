//
//  HotDealCollectionViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 20/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreLocation

class HotDealCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    
    @IBOutlet weak var offerTagValueLabel: UILabel!
    @IBOutlet weak var offerTagView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var offerPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    
    @IBOutlet weak var contentBackgroundView: UIView!
    
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var shadowLayerView: UIView!
    var deal : Deal?
    var makeFavouriteActionBlock : ((_ deal : Deal)->())?
    var currentUserLocation : CLLocation?

    
    override func awakeFromNib() {
        super.awakeFromNib()

        offerTagView.transform  = CGAffineTransform(rotationAngle: (.pi/4)*7)
      
        self.shadowLayerView.layer.cornerRadius = 6.0
        
        self.shadowLayerView.layer.shadowColor = Constants.blackDarkColor.cgColor
        self.shadowLayerView.layer.shadowOpacity = 0.14
        self.shadowLayerView.layer.shadowOffset = CGSize.zero
        self.shadowLayerView.layer.shadowRadius = 5
        self.shadowLayerView.layer.cornerRadius = 6.0
        self.shadowLayerView.clipsToBounds = false
        
        self.contentBackgroundView.clipsToBounds = true
        self.contentBackgroundView.layer.cornerRadius = 6.0
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
        self.deal = deal
        if let images = deal.images, images.count > 0 {
            self.dealImageView?.af_setImage(withURL: URL(string: image_service_url + images.first!)!)
        }
        self.vendorNameLabel.text = deal.vendor!.name!
//        self.originalPriceLabel.attributedText = self.originalPriceAttributedText(value: "\(deal.originalPrice!)")
//        self.offerPriceLabel.text = "\(deal.dealPrice!)"
        
        if let originalPrice = deal.originalPrice {
            var originalPriceString = "\(originalPrice)"
            if let currencySymbol = deal.currencySymbol {
                originalPriceString = currencySymbol + " " + originalPriceString
            }
            self.originalPriceLabel.attributedText = self.originalPriceAttributedText(value: originalPriceString)
        }
        if let offerPrice = deal.dealPrice {
            var offerPriceString = "\(offerPrice)"
            if let currencySymbol = deal.currencySymbol {
                offerPriceString = currencySymbol + " " + offerPriceString
            }
            self.offerPriceLabel.text = offerPriceString
        }
        
        
        self.distanceValueLabel.text = "2 kms away"
        self.descriptionLabel.attributedText = self.dealTitleAttributedText(title: deal.dealDescription!)
        if let originalPrice = deal.originalPrice, let offerPrice = deal.dealPrice {
            self.offerTagValueLabel.text = "\(Int((Float(offerPrice)/Float(originalPrice))*100))% off"
        }
        if let favourite = deal.isFavourited {
            self.favouriteButton.setBackgroundImage(UIImage(named: favourite ? "make_favourite" : "makeFavouriteTransparent"), for: UIControlState.normal)
        } else {
            self.favouriteButton.setBackgroundImage(UIImage(named: "makeFavouriteTransparent"), for: UIControlState.normal)
        }
        if let vendorLat = self.deal?.vendor?.locationLat, let vendorLong = self.deal?.vendor?.locationLong, let currentUserLocation = self.currentUserLocation {
            let vendorLocation = CLLocation(latitude: vendorLat, longitude: vendorLong)
            let distance = vendorLocation.distance(from: currentUserLocation)
            if Int(Double(distance)/Double(1000)) == 0 {
                let distanceInKm = Int(distance)
                self.distanceValueLabel.text = "\(distanceInKm) m away"
            } else {
                let distanceInKm = Int(Double(distance)/Double(1000))
                if Int(Double(distance)/Double(1000)) == 1 {
                    self.distanceValueLabel.text = "\(distanceInKm) km away"
                } else {
                    self.distanceValueLabel.text = "\(distanceInKm) kms away"
                }
            }
        }
    }
    
    @IBAction func makeFavouriteButtonClicked(_ sender: UIButton) {
        if let makeFavouriteActionBlock = makeFavouriteActionBlock {
            makeFavouriteActionBlock(deal!)
        }
        self.favouriteButton.setBackgroundImage(UIImage(named: "make_favourite"), for: UIControlState.normal)
    }

}
