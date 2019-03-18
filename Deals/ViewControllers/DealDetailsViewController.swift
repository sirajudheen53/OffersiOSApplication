//
//  DealDetailsViewController.swift
//  Test
//
//  Created by qbuser on 21/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreGraphics
import SVProgressHUD
import CoreLocation
import QpayPayment

class DealDetailsViewController: BaseViewController, QPRequestProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var dealId : Int?
    var deal : Deal?
    var dealCode : String?
    var qpRequestParams : QPRequestParameters!

    @IBOutlet weak var offerDetailsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dealImageViewBottomConstraint: NSLayoutConstraint!

    var animationInProgress = false
    var showingSheltonAnimation = false
    
    @IBOutlet weak var imageSliderView : UIView!
    @IBOutlet weak var imageSlider : UIPageControl!
    @IBOutlet weak var imageSliderCollectionView : UICollectionView!

    @IBOutlet weak var addressIconImageView: UIImageView!
    @IBOutlet weak var boughtPeopelIconImageView: UIImageView!
    @IBOutlet weak var viewedPeopleIconImageView: UIImageView!
    @IBOutlet weak var locateButtonImageView: UIImageView!
    @IBOutlet weak var phoneContactButton: UIButton!
    @IBOutlet weak var buyMoreButton: UIButton!
    @IBOutlet weak var couponContactButton: UIButton!
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var originalPriceValuLabel: UILabel!
    @IBOutlet weak var offerPriceValueLabel: UILabel!
    @IBOutlet weak var validUptoValueLabel: UILabel!
    @IBOutlet weak var vendorAddressValueLabel: UILabel!
    @IBOutlet weak var numberOfPeopleViewedValueLabel: UILabel!
    @IBOutlet weak var numberOfPeoplePurchased: UILabel!
    @IBOutlet weak var viewsTitleLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var phoneContactImageView: UIImageView!
    @IBOutlet weak var offerPercentageStripLabel: UILabel!
    @IBOutlet weak var offerDetailsView: UIView!
    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var dealDetailsButton: UIButton!
    @IBOutlet weak var dashedView: UIView!
    @IBOutlet weak var moreDetailsRightArrowButton: UIButton!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet weak var purchasesTitleLabel: UILabel!
    @IBOutlet weak var maskedView: UIView!
    @IBOutlet weak var couponVendorAddressLabel: UILabel!
    @IBOutlet weak var couponDistanceValueLabel: UILabel!
    @IBOutlet weak var couponQRCodeImageView: UIImageView!
    @IBOutlet weak var couponCodeLabelView: UILabel!
    @IBOutlet weak var couponExpiresValueLabel: UILabel!
    @IBOutlet weak var dealInfoView: UIView!
    @IBOutlet weak var offerDetailsHeightContstraint: NSLayoutConstraint!
    @IBOutlet weak var makeFavouriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var offerStrinp: UIImageView!
    @IBOutlet weak var offerExpiredView: UIView!
    @IBOutlet weak var coupnInfoView: UIView!
    @IBOutlet weak var dealInfoEnableLocationButton: UIButton!
    @IBOutlet weak var couponeLocationEnableButton: UIButton!
    @IBOutlet weak var dealLocateButton: UIButton!
    @IBOutlet weak var couponLocateButton: UIButton!

    
    var dealInfoViewDragging = UIPanGestureRecognizer()
    var couponInfoViewDragging = UIPanGestureRecognizer()
    var linesConvergingAnimation : UIViewPropertyAnimator = UIViewPropertyAnimator()
    override func viewDidLoad() {
        self.offerDetailsViewBottomConstraint.constant = -300
       qpRequestParams =   QPRequestParameters(viewController: self)
        qpRequestParams.delegate = self
        analyticsScreenName = "Deal Details View"
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        if let _ = deal {
            self.configureUIElements()
        } else {
            fetchDealDetailsFromServer()
        }

        self.title = "Details"
        drawDottedLine(start: CGPoint(x: dashedView.bounds.minX, y: dashedView.bounds.minY),
                       end: CGPoint(x: dashedView.bounds.maxX, y: dashedView.bounds.minY), view: dashedView)
        
        dealInfoViewDragging = UIPanGestureRecognizer(target: self, action: #selector(self.infoViewDragged(panGesture:)))
        couponInfoViewDragging = UIPanGestureRecognizer(target: self, action: #selector(self.infoViewDragged(panGesture:)))
        offerDetailsView.isUserInteractionEnabled = true
        offerDetailsView.addGestureRecognizer(dealInfoViewDragging)
        
//        dealInfoView.isUserInteractionEnabled = true
//        dealInfoView.addGestureRecognizer(couponInfoViewDragging)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func infoViewDragged(panGesture : UIPanGestureRecognizer){
        let translation  = panGesture.translation(in: self.dealInfoView)
        let velocity = panGesture.velocity(in: self.dealInfoView)
        self.imageSliderCollectionView.collectionViewLayout.invalidateLayout()

        if self.animationInProgress {
            return
        }
        
        
        if(panGesture.state == UIGestureRecognizerState.ended)
        {
            if velocity.y > 1000  {
                //Full view
                if self.offerDetailsViewBottomConstraint.constant != -300 {
                    offerDetailsViewBottomConstraint.constant = -300
                    if let images = deal?.images, images.count > 1 {
                        self.imageSlider.isHidden = false
                    }
                    animationInProgress = true
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                    }) { (status) in
                        self.animationInProgress = false
                    }
                }
                return
            } else if velocity.y < -1000  {
                //Deal full view
                if self.offerDetailsViewBottomConstraint.constant != 0 {
                    offerDetailsViewBottomConstraint.constant = 0
                    self.imageSlider.isHidden = true
                    animationInProgress = true
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                    }) { (status) in
                        self.animationInProgress = false
                    }
                }
                return
            }
            
            if translation.y < 300 {
                //Deal full view
                self.offerDetailsViewBottomConstraint.constant = 0
                self.imageSlider.isHidden = true
                animationInProgress = true
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                }) { (status) in
                    self.animationInProgress = false
                }
            } else {
                //Full Screen
                self.offerDetailsViewBottomConstraint.constant = -300
                if let images = deal?.images, images.count > 1 {
                    self.imageSlider.isHidden = false
                }
                animationInProgress = true
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                }) { (status) in
                    self.animationInProgress = false
                }
            }
        } else {
            if translation.y > 0 {
                if translation.y > 300 {
                    //Full Screen
                    if let images = deal?.images, images.count > 1 {
                        self.imageSlider.isHidden = false
                    }
                    offerDetailsViewBottomConstraint.constant = -300
                } else if offerDetailsViewBottomConstraint.constant != -300 {
                    self.imageSlider.isHidden = true
                    offerDetailsViewBottomConstraint.constant = -translation.y
                }
            } else if translation.y > -300 && offerDetailsViewBottomConstraint.constant != 0 {
                self.imageSlider.isHidden = true
                //Dragging up
                offerDetailsViewBottomConstraint.constant = -(300 + translation.y)
            }

        }

        
    }
    
    func titleAttributedText(title : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.7
        
        let attributes = [NSAttributedStringKey.font : Constants.mediumFontWithSize(size: 14.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.lightDarkColor]
        let requiredString = NSAttributedString(string: title, attributes: attributes)
        return requiredString
    }
    
    
    
    func moreDetailsAttributedText(title : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.7
        
        let attributes = [NSAttributedStringKey.font : Constants.compactTextRegulaFontWithSize(size: 14.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.darkColor]
        let requiredString = NSAttributedString(string: title, attributes: attributes)
        return requiredString
    }
    
    func addressAttributedText(address : String) -> NSAttributedString {
        let addressText = address.replacingOccurrences(of: "--", with: " \n")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.7
        
        let attributes = [NSAttributedStringKey.font : Constants.compactTextRegulaFontWithSize(size: 14.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.lightDarkColor]
        let requiredString = NSAttributedString(string: addressText, attributes: attributes)
        return requiredString
    }
    
    @objc func userLocationUpdated(notification : Notification) {
        updateDistanceValue()
    }
    
    @IBAction func locateButtonClicked(_ sender: Any) {
        if let latitude = deal?.vendor?.locationLat, let longitude = deal?.vendor?.locationLong, latitude != 0, longitude != 0 {
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                let urlString = "http://maps.google.com/?daddr=\(latitude),\(longitude)&directionsmode=driving"
                
                UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
            }
            else {
                let urlString = "http://maps.apple.com/maps?daddr=\(latitude),\(longitude)&dirflg=d"

                UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
            }
        } else {
            UIView.showWarningMessage(title: "Oops!", message: "No location details found for this vendor")

        }
    }
    
    @IBAction func enableLoctionButtonClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Dollor Deals", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                    
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        // check the permission status
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.locationManager.startUpdatingLocation()
            }
        // get the user location
        case .notDetermined, .restricted, .denied:
            // redirect the users to settings
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func purchaseBoughtAttributedText(text : String) -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font : Constants.compactTextRegulaFontWithSize(size: 12.0),
                          NSAttributedStringKey.foregroundColor : Constants.darkGrey]
        let requiredString = NSMutableAttributedString(string: text, attributes: attributes)
        requiredString.addAttribute(NSAttributedStringKey.kern, value: 1.0, range: NSMakeRange(0, requiredString.length))
        return requiredString
    }
    
    func contactTitleAttributedText(text : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.7
        
        let attributes = [NSAttributedStringKey.font : Constants.compactTextRegulaFontWithSize(size: 12.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.extraGreyColor]
        let requiredString = NSAttributedString(string: text, attributes: attributes)
        return requiredString
    }
    
    func validUptoAttributedText(validUptoDate : String) -> NSAttributedString {
        let requiredString = "Offer valid till " + validUptoDate
        let attributes = [NSAttributedStringKey.font : Constants.regularFontWithSize(size: 12.0)]
        let requiredAttributedString = NSMutableAttributedString(string: requiredString, attributes: attributes)
        requiredAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: Constants.extraGreyColor, range: NSMakeRange(0, "Offer valid till ".count))
        requiredAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: Constants.redColor, range: NSMakeRange("Offer valid till ".count, requiredString.count - "Offer valid till ".count))
        return requiredAttributedString
    }
    
    func originalPriceAttributedText(value : String) -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font : Constants.lightFontWithSize(size: 18),
                          NSAttributedStringKey.foregroundColor : Constants.lightDarkColor,
                          NSAttributedStringKey.strikethroughColor : Constants.lightDarkColor,
        NSAttributedStringKey.strikethroughStyle : 1] as [NSAttributedStringKey : Any]
        let requiredString = NSMutableAttributedString(string: value, attributes: attributes)
        return requiredString
    }
    
    func offerPercentageStripValueAttributedString(value : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.8
        let attributes = [NSAttributedStringKey.font : Constants.mediumFontWithSize(size: 14),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : UIColor.white]
        let requiredString = NSMutableAttributedString(string: value, attributes: attributes)
        return requiredString
    }
    
    func showDealDetailsLoadingAnimation() {
        showingSheltonAnimation = true
        imageSliderCollectionView.reloadData()

        offerPriceValueLabel.isHidden = true
        originalPriceValuLabel.isHidden = true
        priceTitleLabel.isHidden = true
        moreDetailsRightArrowButton.isHidden = true
        dealDetailsButton.isHidden = true
        buyNowButton.isHidden = true
        dealInfoEnableLocationButton.isHidden = true
        locateButtonImageView.isHidden = true
        phoneContactImageView.isHidden = true
        dealLocateButton.isHidden = true
        phoneContactButton.isHidden = true
        numberOfPeopleViewedValueLabel.isHidden = true
        numberOfPeoplePurchased.isHidden = true
        viewedPeopleIconImageView.isHidden = true
        boughtPeopelIconImageView.isHidden = true
        shareButton.isHidden = true
        makeFavouriteButton.isHidden = true
        offerPercentageStripLabel.isHidden = true
        buyMoreButton.isHidden = true
        addressIconImageView.isHidden = true
        offerStrinp.isHidden = true
        validUptoValueLabel.showAnimatedGradientSkeleton()
        viewsTitleLabel.showAnimatedGradientSkeleton()
        purchasesTitleLabel.showAnimatedGradientSkeleton()
        vendorAddressValueLabel.showAnimatedGradientSkeleton()
        vendorNameLabel.showAnimatedGradientSkeleton()
        distanceValueLabel.showAnimatedGradientSkeleton()
        offerTitleLabel.showGradientSkeleton()
  }
    
    func stopDealDetailsLoadingAnimation() {
        showingSheltonAnimation = false
        imageSliderCollectionView.reloadData()
        
        offerPriceValueLabel.isHidden = false
        originalPriceValuLabel.isHidden = false
        priceTitleLabel.isHidden = false
        moreDetailsRightArrowButton.isHidden = false
        dealDetailsButton.isHidden = false
        buyNowButton.isHidden = false
        dealInfoEnableLocationButton.isHidden = false
        locateButtonImageView.isHidden = false
        phoneContactImageView.isHidden = false
        dealLocateButton.isHidden = false
        phoneContactButton.isHidden = false
        numberOfPeopleViewedValueLabel.isHidden = false
        numberOfPeoplePurchased.isHidden = false
        viewedPeopleIconImageView.isHidden = false
        boughtPeopelIconImageView.isHidden = false
        shareButton.isHidden = false
        makeFavouriteButton.isHidden = false
        offerPercentageStripLabel.isHidden = false
        buyMoreButton.isHidden = false
        addressIconImageView.isHidden = false
        offerStrinp.isHidden = false
        validUptoValueLabel.hideSkeleton()
        viewsTitleLabel.hideSkeleton()
        purchasesTitleLabel.hideSkeleton()
        vendorAddressValueLabel.hideSkeleton()
        vendorNameLabel.hideSkeleton()
        distanceValueLabel.hideSkeleton()
        offerStrinp.hideSkeleton()
        offerTitleLabel.hideSkeleton()
 }

    func configureUIElements() {
        makeViewedAPI()
        imageSliderCollectionView.reloadData()
       if let deal = deal, deal.purchaseCode != "" && deal.endDate > Date() {
            showDealCodeView()
        } else {
            dealInfoView.isHidden = false
            coupnInfoView.isHidden = true
        }
        if let deal = self.deal {
            if let vendor = deal.vendor {
                makeFavouriteButton.isSelected = deal.isFavourited
                self.vendorNameLabel.text = vendor.name ?? "-"
                if let currencySymbol = self.deal?.currencySymbol, let offerPrice = self.deal?.dealPrice {
                    self.offerPriceValueLabel.text = currencySymbol + " \(offerPrice)"
                } else {
                    self.offerPriceValueLabel.text = "-"
                }
                if let originalPrice = self.deal?.originalPrice, let currencySymbol = self.deal?.currencySymbol {
                    self.originalPriceValuLabel.attributedText = self.originalPriceAttributedText(value: currencySymbol + " \( originalPrice)")
                } else {
                    self.originalPriceValuLabel.attributedText = self.originalPriceAttributedText(value: "-")

                }
                if let vendorAddress = self.deal?.vendor?.address {
                    self.vendorAddressValueLabel.attributedText = self.addressAttributedText(address: vendorAddress)
                } else {
                    self.vendorAddressValueLabel.attributedText = self.addressAttributedText(address: "-")
                }
                if let numberOfPeopleViewed = self.deal?.numberOfPeopleViewed {
                    self.numberOfPeopleViewedValueLabel.text = "\(numberOfPeopleViewed)"
                } else {
                    self.numberOfPeopleViewedValueLabel.text = "-"
                }
                
                if let images = deal.images {
                    imageSlider.numberOfPages = images.count
                    imageSlider.hidesForSinglePage = true
                }
                
                if deal.numberOfPurchases == 0 {
                    buyMoreButton.isHidden = true
                } else if deal.numberOfPurchases < deal.allowedSimultaneous {
                    buyMoreButton.isHidden = false
                } else {
                    buyMoreButton.isHidden = true
                }
                
                if deal.endDate < Date() {
                    buyMoreButton.isHidden = true
                    buyNowButton.isHidden = true
                    offerExpiredView.isHidden = false
                    offerPercentageStripLabel.isHidden = true
                    offerStrinp.isHidden = true
                    shareButton.isHidden = true
                    makeFavouriteButton.isHidden = true
                    offerDetailsHeightContstraint.constant = 385
                    validUptoValueLabel.isHidden = true
                }
                
            }
        }
        self.numberOfPeoplePurchased.text = "\(self.deal!.numberOfPeopleBought)"
        self.offerTitleLabel.attributedText = self.titleAttributedText(title: self.deal!.dealDescription)
        self.dealDetailsButton.setAttributedTitle(self.moreDetailsAttributedText(title: "More Details"), for: UIControlState.normal)
        self.purchasesTitleLabel.attributedText = self.purchaseBoughtAttributedText(text: "PURCHASES")
        self.viewsTitleLabel.attributedText = self.purchaseBoughtAttributedText(text: "VIEWS")
        self.phoneContactButton.setAttributedTitle(self.contactTitleAttributedText(text: "Contact"), for: UIControlState.normal)
        self.validUptoValueLabel.attributedText = self.validUptoAttributedText(validUptoDate: deal!.endDate.defaultStringFormat())
        
        let offerPercent : Double = (Double(deal!.originalPrice - deal!.dealPrice)/Double(self.deal!.originalPrice)*100)
        self.offerPercentageStripLabel.attributedText = offerPercentageStripValueAttributedString(value: "\(Int(offerPercent)) % off")
        
        updateDistanceValue()
    }
    
    func updateDistanceValue() {
        guard let _ = deal else {
            return
        }
        
        guard let userLocationStatus = UserDefaults.standard.value(forKey: "UserAuthorizationForLocation") as? Bool, userLocationStatus else {
            couponDistanceValueLabel.isHidden = true
            distanceValueLabel.isHidden = true
            
            couponeLocationEnableButton.isHidden = false
            dealInfoEnableLocationButton.isHidden = false
            return
        }
        couponDistanceValueLabel.isHidden = false
        distanceValueLabel.isHidden = false
        
        couponeLocationEnableButton.isHidden = true
        dealInfoEnableLocationButton.isHidden = true
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentLocation = appDelegate.currentLocation {
            if let vendorLong = self.deal?.vendor?.locationLong, let vendorLat = self.deal?.vendor?.locationLat {
                let vendorLocation = CLLocation(latitude: vendorLat, longitude: vendorLong)
                let distance = vendorLocation.distance(from: currentLocation)
                if Int(Double(distance)/Double(1000)) == 0 {
                    let distanceInKm = Int(distance)
                    couponDistanceValueLabel.text = "\(distanceInKm) m away"
                    distanceValueLabel.text = "\(distanceInKm) m away"
                } else {
                    let distanceInKm = Int(Double(distance)/Double(1000))
                    if Int(Double(distance)/Double(1000)) == 1 {
                        couponDistanceValueLabel.text = "\(distanceInKm) km away"
                        distanceValueLabel.text = "\(distanceInKm) km away"
                    } else {
                        couponDistanceValueLabel.text = "\(distanceInKm) kms away"
                        distanceValueLabel.text = "\(distanceInKm) kms away"
                    }
                }
            } else {
                couponDistanceValueLabel.text = "Could not find vendor location"
                distanceValueLabel.text = "Could not find vendor location"
            }
        } else {
            distanceValueLabel.text = "Could not find user location"
        }
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    func showDealCodeView() {
        dealInfoView.isHidden = true
        coupnInfoView.isHidden = false
        
        self.couponCodeLabelView.text = deal?.purchaseCode ?? ""
        if let vendorAddress = self.deal?.vendor?.address {
            self.couponVendorAddressLabel.attributedText = self.addressAttributedText(address: vendorAddress)
        } else {
            self.couponVendorAddressLabel.attributedText = self.addressAttributedText(address: "-")
        }
        
        if let expiryDate = self.deal?.purchaseExpiry {
            if expiryDate < Date() {
                maskedView.isHidden = false
                self.couponExpiresValueLabel.text = "Coupon Expired"
            } else {
                maskedView.isHidden = true
                let date2: Date = Date() // Same you did before with timeNow variable
                
                let calender:Calendar = Calendar.current
                let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date2, to: expiryDate)
                if let hour = components.hour, let minuites = components.minute {
                    self.couponExpiresValueLabel.text = "Expires in \(hour) h \(minuites) m"
                }
            }
        }
        
        couponQRCodeImageView.image = UIView.createQRFromString(deal?.purchaseCode ?? "", size: couponQRCodeImageView.frame.size)
    }
    
    // MARK: - IBAction Methods
    
    func initiatePayment() {
        qpRequestParams.gatewayId = "017146316"
        qpRequestParams.secretKey = "2-LHwxDLOVHC3pB5"
        qpRequestParams.name = "Dollor Deals"
        qpRequestParams.address = "Dollor Deals - Qatar"
        qpRequestParams.city = "Doha"
        qpRequestParams.state = "Doha"
        qpRequestParams.country  = "QA"
        qpRequestParams.email = User.getProfile()?.email ?? "info@dollordeals.com"
        qpRequestParams.currency = "QAR"
        qpRequestParams.referenceId = UUID().uuidString
        qpRequestParams.phone = "\(User.getProfile()?.phoneNumber ?? "")"
        qpRequestParams.amount = Double(deal?.dealPrice ?? 1) //any float value
        qpRequestParams.mode = "TEST"
        qpRequestParams.productDescription = "A Deal from Dollor Deals"
        qpRequestParams.sendRequest()
    }
    
    @IBAction func buyNowButtonClicked(_ sender: UIButton) {
        if let _ = User.getProfile()?.token {
            guard let userPhoneNumber = User.getProfile()?.phoneNumber, userPhoneNumber != "" else {
                self.performSegue(withIdentifier: "showPhoneNumberInput", sender: nil)
                return
            }
            initiatePayment()
        }
        else {
                self.performSegue(withIdentifier: "showLoginPopup", sender: nil)
            }

    }
    
    
    @IBAction func contactButtonClicked(_ sender: Any) {
        if let vendorPhone = deal?.vendor?.phoneNumber, let url = URL(string: "telprompt://\(vendorPhone)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        let text = "Grab awesome deals from\n\n"
        let myWebsite = URL(string:"https://www.dollordeals.com")
        let shareAll = [text, myWebsite as Any] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func makeViewedAPI() {
        if let serverToken = User.getProfile()?.token {
            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            if let deal = deal {
                BaseWebservice.performRequest(function: .userView, requestMethod: .post, params: ["deal_id" : deal.dealId as AnyObject], headers: userProfileFetchHeader, onCompletion: { (response, error) in
                    
                    })
            }
        }
    }
    
    @IBAction func makeFavouriteButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let serverToken = User.getProfile()?.token {
            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            if let deal = deal {
                let flag = deal.isFavourited ? "false" : "true"
                deal.isFavourited = !deal.isFavourited
                BaseWebservice.performRequest(function: .makeFavourite, requestMethod: .post, params: ["deal_id" : deal.dealId as AnyObject, "flag" : flag as AnyObject], headers: userProfileFetchHeader, onCompletion: { (response, error) in
                    if let error = error {
                        UIView.showWarningMessage(title: "Sorry !!!", message: error.localizedDescription)
                    } else if let response = response as? [String : Any?] {
                        if response["status"] as? String == "success" {
                            NotificationCenter.default.post(Notification.init(name: Notification.Name("userProfileUpdated")))
                        } else if let message = response["message"] as? String {
                            UIView.showWarningMessage(title: "Oops !", message: message)
                        }  else {
                            UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                        }
                    } else {
                        UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                    }
                })
            }
        }
    }
    
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            NotificationCenter.default.post(name: NSNotification.Name("detailsViewDismissed"), object: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationView = segue.destination as? MoreDetailsViewController, segue.identifier == "showMoreDetailsView" {
            if let deal = deal {
                destinationView.deal = deal
            }
        }
    }
    
    func fetchDealDetailsFromServer() {
        showDealDetailsLoadingAnimation()
        
        guard let dealId = dealId else {
            UIView.showWarningMessage(title: "Sorry !!!", message: "We could not find deal you are searching for...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.dismiss(animated: false, completion: nil)
                self.stopDealDetailsLoadingAnimation()
            }
            return
        }
        
        var tokenHeader = [String : String]()
        if let token = User.getProfile()?.token {
            tokenHeader = ["Authorization" : "Token \(token)"]
        }
  
        BaseWebservice.performRequest(function: WebserviceFunction.fetchDeal, requestMethod: .get, params: ["deal_id" : dealId as AnyObject], headers: tokenHeader) { (response, error) in
            self.stopDealDetailsLoadingAnimation()
            if let response = response as? [String : Any] {
                if let status = response["status"] as? String, status == "success" {
                    if let dealProperties = response["deal"] as? [String : Any] {
                        self.deal = Deal.dealObjectFromProperty(property: dealProperties)
                        self.configureUIElements()
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                    }
                } else {
                    if let message = response["Sorry !!!"] as? String {
                        self.dismiss(animated: true, completion: nil)
                        UIView.showWarningMessage(title: "Sorry !!!", message: message)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
                UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
            }
        }
    }
    
    func makePurchase(orderId : Any, transactionId : Any) {
        if let serverToken = User.getProfile()?.token {
            guard let userPhoneNumber = User.getProfile()?.phoneNumber, userPhoneNumber != "" else {
                self.performSegue(withIdentifier: "showPhoneNumberInput", sender: nil)
                return
            }
            SVProgressHUD.show()
            let header = ["Authorization" : "Token \(serverToken)"]
            
            var params = ["deal_id" : deal!.dealId as AnyObject];
            params["transaction_id"] = transactionId as AnyObject
            params["order_id"] = orderId as AnyObject
            
            BaseWebservice.performRequest(function: .makePurchase, requestMethod: .post, params: params, headers: header, onCompletion: { (response, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    UIView.showWarningMessage(title: "Sorry !!!", message: error.localizedDescription)
                } else if let response = response as? [String : Any?] {
                    if response["status"] as? String == "success" {
                        NotificationCenter.default.post(Notification.init(name: Notification.Name("userProfileUpdated")))
                        if let purchase = response["purchase"] as? [String : Any] {
                            if let code = purchase["code"] as? String {
                                self.deal?.purchaseCode = code
                            }
                            if let purchaseExpiry = purchase["expiry_date"] as? Double {
                                self.deal?.purchaseExpiry = Date(timeIntervalSince1970: purchaseExpiry)
                            }
                            self.deal!.numberOfPurchases += 1
                            if self.deal!.numberOfPurchases < self.deal!.allowedSimultaneous {
                                self.buyMoreButton.isHidden = false
                            } else {
                                self.buyMoreButton.isHidden = true
                            }
                        }
                        self.showDealCodeView()
                        
                    } else if let message = response["message"] as? String {
                        UIView.showWarningMessage(title: "Oops !", message: message)
                    } else {
                        UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                    }
                } else {
                    UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                }
            })
        } else {
            self.performSegue(withIdentifier: "showLoginPopup", sender: nil)
        }
    }
    
    func qpResponse(_ response: NSDictionary) {
        if let response = response as? [String : Any] {
            if let status = response["status"] as? String, let amount = response["amount"] as? Double, status == "success", amount == Double(deal!.dealPrice), let transactionId = response["transactionId"], let orderId = response["orderId"] {
                makePurchase(orderId: orderId, transactionId: transactionId)
            } else {
                UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with your payment. Please contract our customer care.")
            }
        } else {
            UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with your payment. Please contract our customer care.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dealImages = deal?.images {
            if dealImages.count == 0 {
                return 1
            }
            return dealImages.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageSliderCollectionViewCell
        if let images = deal?.images {
            imageCell.imageUrl = images[indexPath.row]
            imageCell.loadImage()
        } else if showingSheltonAnimation {
            imageCell.showSkeltonAnimation = showingSheltonAnimation
            imageCell.loadImage()
        }
        return imageCell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        imageSlider.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 10, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 5, 0, 5)
    }
}


