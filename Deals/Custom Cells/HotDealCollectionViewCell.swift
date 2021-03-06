//
//  HotDealCollectionViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 20/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreLocation
import SkeletonView

class HotDealCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    
    @IBOutlet weak var offerTagValueLabel: UILabel!
    @IBOutlet weak var offerTagView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var offerPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    
    @IBOutlet weak var enableLocationButton: UIButton!
    @IBOutlet weak var contentBackgroundView: UIView!
    
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var shadowLayerView: UIView!
    var deal : Deal?
    var makeFavouriteActionBlock : ((_ deal : Deal)->())?
    var enableLocationBlock : (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self, selector: #selector(self.userLocationUpdated(notification:)), name: NSNotification.Name("locationUpdated"), object: nil)
        
        showLoadingAnimation()
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
        let attributes = [NSAttributedString.Key.font : Constants.regularFontWithSize(size: 14),
                          NSAttributedString.Key.foregroundColor : Constants.appliationGreyColor,
                          NSAttributedString.Key.strikethroughColor : Constants.appliationGreyColor,
                          NSAttributedString.Key.strikethroughStyle : 1] as [NSAttributedString.Key : Any]
        let requiredString = NSMutableAttributedString(string: value, attributes: attributes)
        return requiredString
    }
    
    @IBAction func enableLocationButtonClicked(_ sender: Any) {
        if let block = enableLocationBlock {
            block()
        }
    }
    
    @objc func userLocationUpdated(notification : Notification) {
        updateDistanceValue()
    }
    
    func dealTitleAttributedText(title : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.8
        
        let attributes = [NSAttributedString.Key.font : Constants.compactTextRegulaFontWithSize(size: 12.0),
                          NSAttributedString.Key.paragraphStyle : paragraphStyle,
                          NSAttributedString.Key.foregroundColor : Constants.dimGrey]
        let requiredString = NSAttributedString(string: title, attributes: attributes)
        return requiredString
    }
    
    func showLoadingAnimation() {
        offerTagView.isHidden = true
        favouriteButton.isHidden = true
        offerPriceLabel.isHidden = true
        vendorNameLabel.isHidden = true
        distanceValueLabel.isHidden = true
        enableLocationButton.isHidden = true
        dealImageView.showAnimatedSkeleton()
        distanceValueLabel.showAnimatedSkeleton()
        descriptionLabel.showAnimatedSkeleton()
        originalPriceLabel.showAnimatedSkeleton()
    }
    
    func hideLoadingAnimation() {
        dealImageView.hideSkeleton()
        distanceValueLabel.hideSkeleton()
        descriptionLabel.hideSkeleton()
        originalPriceLabel.hideSkeleton()
    }
    
    func customizeCell(deal : Deal) {
        hideLoadingAnimation()
        self.deal = deal
        self.dealImageView.image = UIImage(named: "logo_small")
        dealImageView.contentMode = UIView.ContentMode.center
        if let images = deal.images, images.count > 0 {
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
        offerTagView.isHidden = false
        favouriteButton.isHidden = false
        offerPriceLabel.isHidden = false
        vendorNameLabel.isHidden = false
        self.vendorNameLabel.text = deal.vendor!.name!
//        self.originalPriceLabel.attributedText = self.originalPriceAttributedText(value: "\(deal.originalPrice!)")
//        self.offerPriceLabel.text = "\(deal.dealPrice!)"
        
            var originalPriceString = "\(deal.originalPrice)"
            originalPriceString = deal.currencySymbol + " " + originalPriceString
            self.originalPriceLabel.attributedText = self.originalPriceAttributedText(value: originalPriceString)
            var offerPriceString = "\(deal.dealPrice)"
            offerPriceString = deal.currencySymbol + " " + offerPriceString
            self.offerPriceLabel.text = offerPriceString
        
        
        self.distanceValueLabel.text = "2 kms away"
        self.descriptionLabel.attributedText = self.dealTitleAttributedText(title: deal.dealDescription)
        if deal.originalPrice > 0 {
            self.offerTagValueLabel.text = "\(Int((Float(deal.originalPrice - deal.dealPrice)/Float(deal.originalPrice))*100))% off"
        }
        self.favouriteButton.setBackgroundImage(UIImage(named: deal.isFavourited ? "make_favourite" : "makeFavouriteTransparent"), for: UIControl.State.normal)

        updateDistanceValue()

    }
    
    func updateDistanceValue() {
        guard let _ = deal else {
            return
        }
        
        guard let userLocationStatus = UserDefaults.standard.value(forKey: "UserAuthorizationForLocation") as? Bool, userLocationStatus else {
            distanceValueLabel.isHidden = true
            enableLocationButton.isHidden = false
            return
        }
        distanceValueLabel.isHidden = false
        enableLocationButton.isHidden = true
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentLocation = appDelegate.currentLocation {
            if let vendorLong = self.deal?.vendor?.locationLong, let vendorLat = self.deal?.vendor?.locationLat {
                let vendorLocation = CLLocation(latitude: vendorLat, longitude: vendorLong)
                let distance = vendorLocation.distance(from: currentLocation)
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
            } else {
                self.distanceValueLabel.text = "Could not find vendor location"
            }
        } else {
            self.distanceValueLabel.text = "Could not find user location"
        }
    }
    
    @IBAction func makeFavouriteButtonClicked(_ sender: UIButton) {
        if let makeFavouriteActionBlock = makeFavouriteActionBlock {
            makeFavouriteActionBlock(deal!)
        }
        self.favouriteButton.setBackgroundImage(UIImage(named: "make_favourite"), for: UIControl.State.normal)
    }

}
