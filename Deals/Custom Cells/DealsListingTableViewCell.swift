//
//  DealsListingTableViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 06/07/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreLocation

class DealsListingTableViewCell: UITableViewCell {

    var deal : Deal?
    
    @IBOutlet weak var offerPercentValueLabel: UILabel!
    @IBOutlet weak var vendorNameValueLabel: UILabel!
    @IBOutlet weak var distanceToVendorValueLabel: UILabel!
    @IBOutlet weak var offerDescriptionValueLabel: UILabel!
    @IBOutlet weak var offerPriceValueLabel: UILabel!
    @IBOutlet weak var originalPriceValueLabel: UILabel!
    @IBOutlet weak var offerTagView: UIView!
    @IBOutlet weak var dealContentView: UIView!
    @IBOutlet weak var dealImageContentView: UIView!
    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var currentUserLocation : CLLocation?
    var makeFavouriteActionBlock : ((_ deal : Deal)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.offerTagView.transform  = CGAffineTransform(rotationAngle: (.pi/4)*7)
        self.backgroundColor = UIColor.clear
        
        self.dealContentView.layer.cornerRadius = 6.0
        
        self.dealContentView.layer.shadowColor = Constants.blackDarkColor.cgColor
        self.dealContentView.layer.shadowOpacity = 0.14
        self.dealContentView.layer.shadowOffset = CGSize.zero
        self.dealContentView.layer.shadowRadius = 6.0
        self.dealContentView.layer.cornerRadius = 6.0
        self.dealContentView.clipsToBounds = false
        
        self.dealImageContentView.layer.cornerRadius = 6.0
        self.dealImageContentView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        dealImageView.contentMode = UIViewContentMode.center
        self.dealImageView.image = UIImage(named: "logo_small")
    }
    
    func customizeCell(deal : Deal) {
        self.deal = deal
        if let vendor = deal.vendor {
            self.vendorNameValueLabel.text = vendor.name!
        }
            self.offerDescriptionValueLabel.attributedText = self.dealDescriptionAttributeText(title: deal.dealDescription)
            var originalPriceString = "\(deal.originalPrice)"
                originalPriceString = deal.currencySymbol + " " + originalPriceString
            self.originalPriceValueLabel.attributedText = self.originalPriceAttributedText(value: originalPriceString)
            var offerPriceString = "\(deal.dealPrice)"
                offerPriceString = deal.currencySymbol + " " + offerPriceString
            self.offerPriceValueLabel.text = offerPriceString
        if deal.originalPrice > 0 {
            self.offerPercentValueLabel.text = "\(Int((Float(deal.dealPrice)/Float(deal.originalPrice))*100))% off"
        }
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
            self.favouriteButton.setBackgroundImage(UIImage(named: deal.isFavourited ? "make_favourite" : "makeFavouriteTransparent"), for: UIControlState.normal)
    
        if let vendorLat = self.deal?.vendor?.locationLat, let vendorLong = self.deal?.vendor?.locationLong, let currentUserLocation = self.currentUserLocation {
            print("User location calculated")
            let vendorLocation = CLLocation(latitude: vendorLat, longitude: vendorLong)
            let distance = vendorLocation.distance(from: currentUserLocation)
            if Int(Double(distance)/Double(1000)) == 0 {
                let distanceInKm = Int(distance)
                self.distanceToVendorValueLabel.text = "\(distanceInKm) m away"
            } else {
                let distanceInKm = Int(Double(distance)/Double(1000))
                if Int(Double(distance)/Double(1000)) == 1 {
                    self.distanceToVendorValueLabel.text = "\(distanceInKm) km away"
                } else {
                    self.distanceToVendorValueLabel.text = "\(distanceInKm) kms away"
                }
            }
        } else {

        }
    }
    
    func dealDescriptionAttributeText(title : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.6
        
        let attributes = [NSAttributedStringKey.font : Constants.lightFontWithSize(size: 12.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.blackDarkColor]
        let requiredString = NSAttributedString(string: title, attributes: attributes)
        return requiredString
    }
    
    func originalPriceAttributedText(value : String) -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font : Constants.lightFontWithSize(size: 12.0),
                          NSAttributedStringKey.foregroundColor : Constants.appliationGreyColor,
                          NSAttributedStringKey.strikethroughColor : Constants.appliationGreyColor,
                          NSAttributedStringKey.strikethroughStyle : 1] as [NSAttributedStringKey : Any]
        let requiredString = NSMutableAttributedString(string: value, attributes: attributes)
        return requiredString
    }
    
    @IBAction func makeFavouriteButtonClicked(_ sender: UIButton) {
        if let makeFavouriteActionBlock = makeFavouriteActionBlock {
            makeFavouriteActionBlock(deal!)
        }
        self.favouriteButton.setBackgroundImage(UIImage(named: "make_favourite"), for: UIControlState.normal)
    }
}
