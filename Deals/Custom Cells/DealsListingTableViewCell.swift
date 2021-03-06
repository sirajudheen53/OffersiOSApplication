//
//  DealsListingTableViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 06/07/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreLocation
import SkeletonView

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
    
    @IBOutlet weak var enableLocationButton: UIButton!
    var currentUserLocation : CLLocation?
    var makeFavouriteActionBlock : ((_ deal : Deal)->())?
    var enableLocationBlock : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLocationUpdated(notification:)), name: NSNotification.Name("locationUpdated"), object: nil)

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
        
        
        
        showLoadingAnimation()
        
    }
    
    @objc func userLocationUpdated(notification : Notification) {
        updateDistanceValue()
    }
    
    func showLoadingAnimation() {
        offerTagView.isHidden = true
        offerPriceValueLabel.isHidden = true
        distanceToVendorValueLabel.isHidden = true
        enableLocationButton.isHidden = true
        dealImageView.showAnimatedGradientSkeleton()
        offerTagView.showAnimatedSkeleton()
        vendorNameValueLabel.showAnimatedSkeleton()
        offerDescriptionValueLabel.showAnimatedSkeleton()
        originalPriceValueLabel.showAnimatedSkeleton()
    }
    
    func hideLoadingAnimation() {
        dealImageView.hideSkeleton()
        offerTagView.hideSkeleton()
        vendorNameValueLabel.hideSkeleton()
        offerDescriptionValueLabel.hideSkeleton()
        originalPriceValueLabel.hideSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        dealImageView.contentMode = UIView.ContentMode.center
        self.dealImageView.image = UIImage(named: "logo_small")
    }
    
    @IBAction func enableLocationButtonClicked(_ sender: Any) {
        if let block = enableLocationBlock {
            block()
        }
    }
    
    func customizeCell(deal : Deal) {
        hideLoadingAnimation()
        self.deal = deal
        if let vendor = deal.vendor {
            self.vendorNameValueLabel.text = vendor.name!
        }
            offerTagView.isHidden = false
            offerPriceValueLabel.isHidden = false
            self.offerDescriptionValueLabel.attributedText = self.dealDescriptionAttributeText(title: deal.dealDescription)
            var originalPriceString = "\(deal.originalPrice)"
                originalPriceString = deal.currencySymbol + " " + originalPriceString
            self.originalPriceValueLabel.attributedText = self.originalPriceAttributedText(value: originalPriceString)
            var offerPriceString = "\(deal.dealPrice)"
                offerPriceString = deal.currencySymbol + " " + offerPriceString
            self.offerPriceValueLabel.text = offerPriceString
        if deal.originalPrice > 0 {
            self.offerPercentValueLabel.text = "\(Int((Float(deal.originalPrice - deal.dealPrice)/Float(deal.originalPrice))*100))% off"
        }
        if let images = deal.images, let image = images.first {
            self.dealImageView.af_setImage(withURL: URL(string: image_service_url + image)!,
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
        self.favouriteButton.setBackgroundImage(UIImage(named: deal.isFavourited ? "make_favourite" : "makeFavouriteTransparent"), for: UIControl.State.normal)
        updateDistanceValue()
        
    }
    
    func updateDistanceValue() {
        guard let _ = deal else {
            return
        }
        
        guard let userLocationStatus = UserDefaults.standard.value(forKey: "UserAuthorizationForLocation") as? Bool, userLocationStatus else {
            distanceToVendorValueLabel.isHidden = true
            enableLocationButton.isHidden = false
            return
        }
        distanceToVendorValueLabel.isHidden = false
        enableLocationButton.isHidden = true
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentLocation = appDelegate.currentLocation {
            if let vendorLong = self.deal?.vendor?.locationLong, let vendorLat = self.deal?.vendor?.locationLat {
                let vendorLocation = CLLocation(latitude: vendorLat, longitude: vendorLong)
                let distance = vendorLocation.distance(from: currentLocation)
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
                self.distanceToVendorValueLabel.text = "Could not find vendor location"
            }
        } else {
            self.distanceToVendorValueLabel.text = "Could not find user location"
        }
    }
    
    func dealDescriptionAttributeText(title : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.6
        
        let attributes = [NSAttributedString.Key.font : Constants.lightFontWithSize(size: 12.0),
                          NSAttributedString.Key.paragraphStyle : paragraphStyle,
                          NSAttributedString.Key.foregroundColor : Constants.blackDarkColor]
        let requiredString = NSAttributedString(string: title, attributes: attributes)
        return requiredString
    }
    
    func originalPriceAttributedText(value : String) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.font : Constants.lightFontWithSize(size: 12.0),
                          NSAttributedString.Key.foregroundColor : Constants.appliationGreyColor,
                          NSAttributedString.Key.strikethroughColor : Constants.appliationGreyColor,
                          NSAttributedString.Key.strikethroughStyle : 1] as [NSAttributedString.Key : Any]
        let requiredString = NSMutableAttributedString(string: value, attributes: attributes)
        return requiredString
    }
    
    @IBAction func makeFavouriteButtonClicked(_ sender: UIButton) {
        if let makeFavouriteActionBlock = makeFavouriteActionBlock {
            makeFavouriteActionBlock(deal!)
        }
        self.favouriteButton.setBackgroundImage(UIImage(named: "make_favourite"), for: UIControl.State.normal)
    }
}
