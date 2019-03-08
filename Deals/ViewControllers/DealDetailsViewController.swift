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

class DealDetailsViewController: StatusBarAnimatableViewController, QPRequestProtocol {

    var deal : Deal?
    var dealCode : String?
    var qpRequestParams : QPRequestParameters!

    @IBOutlet weak var scrollView: UIScrollView!
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
    
    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var offerPercentageStripLabel: UILabel!
    @IBOutlet weak var offerDetailsView: UIView!
    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var dealDetailsButton: UIButton!
    @IBOutlet weak var dashedView: UIView!

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
    
    
    
    
    override func viewDidLoad() {
        qpRequestParams =   QPRequestParameters(viewController: self)
        qpRequestParams.delegate = self
        
 //       analyticsScreenName = "Deal Details View"
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true
        self.navigationController?.isNavigationBarHidden = true

        if let deal = deal, deal.purchaseCode != "" && deal.endDate > Date() {
            showDealCodeView()
        } else {
            dealInfoView.isHidden = false
            coupnInfoView.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLocationUpdated(notification:)), name: NSNotification.Name("locationUpdated"), object: nil)

        
        makeViewedAPI()
        self.configureUIElements()
        self.title = "Details"
        drawDottedLine(start: CGPoint(x: dashedView.bounds.minX, y: dashedView.bounds.minY),
                       end: CGPoint(x: dashedView.bounds.maxX, y: dashedView.bounds.minY), view: dashedView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func createQRFromString(_ str: String, size: CGSize) -> UIImage {
        let stringData = str.data(using: .utf8)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        
        let minimalQRimage = qrFilter.outputImage!
        // NOTE that a QR code is always square, so minimalQRimage..width === .height
        let minimalSideLength = minimalQRimage.extent.width
        
        let smallestOutputExtent = (size.width < size.height) ? size.width : size.height
        let scaleFactor = smallestOutputExtent / minimalSideLength
        let scaledImage = minimalQRimage.transformed(
            by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        return UIImage(ciImage: scaledImage,
                       scale: UIScreen.main.scale,
                       orientation: .up)
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
    

    func configureUIElements() {
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
                
                if let images = deal.images, let image = images.first,deal.endDate > Date() {
                    self.dealImageView?.af_setImage(withURL: URL(string: image_service_url + image)!)
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
        
        phoneContactButton.layer.borderColor = Constants.darkGrey.cgColor
        phoneContactButton.layer.borderWidth = 1.0
        phoneContactButton.layer.cornerRadius = 4.0
        phoneContactButton.clipsToBounds = true
        
        couponContactButton.layer.borderColor = Constants.darkGrey.cgColor
        couponContactButton.layer.borderWidth = 1.0
        couponContactButton.layer.cornerRadius = 4.0
        couponContactButton.clipsToBounds = true
        
        couponLocateButton.layer.borderColor = Constants.darkGrey.cgColor
        couponLocateButton.layer.borderWidth = 1.0
        couponLocateButton.layer.cornerRadius = 4.0
        couponLocateButton.clipsToBounds = true
        
        dealLocateButton.layer.borderColor = Constants.darkGrey.cgColor
        dealLocateButton.layer.borderWidth = 1.0
        dealLocateButton.layer.cornerRadius = 4.0
        dealLocateButton.clipsToBounds = true
        
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
        
        couponQRCodeImageView.image = createQRFromString(deal?.purchaseCode ?? "", size: couponQRCodeImageView.frame.size)
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
        qpRequestParams.email = "info@dollordeals.com"
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
                        UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                    } else if let response = response as? [String : Any?] {
                        if response["status"] as? String == "success" {
                            NotificationCenter.default.post(Notification.init(name: Notification.Name("userProfileUpdated")))
                        } else if let message = response["message"] as? String {
                            UIView.showWarningMessage(title: "Oops !", message: message)
                        }  else {
                            UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                        }
                    } else {
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
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
    
    func makePurchase() {
        if let serverToken = User.getProfile()?.token {
            guard let userPhoneNumber = User.getProfile()?.phoneNumber, userPhoneNumber != "" else {
                self.performSegue(withIdentifier: "showPhoneNumberInput", sender: nil)
                return
            }
            SVProgressHUD.show()
            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            BaseWebservice.performRequest(function: .makePurchase, requestMethod: .post, params: ["deal_id" : deal!.dealId as AnyObject], headers: userProfileFetchHeader, onCompletion: { (response, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
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
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                } else {
                    UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                }
            })
        } else {
            self.performSegue(withIdentifier: "showLoginPopup", sender: nil)
        }
    }
    
    func qpResponse(_ response: NSDictionary) {
        if let response = response as? [String : Any] {
            if let status = response["status"] as? String, let amount = response["amount"] as? Double, status == "success", amount == Double(deal!.dealPrice) {
                makePurchase()
            } else {
                UIView.showWarningMessage(title: "Warning", message: "Something went wrong with your payment. Please contract our customer care.")
            }
        } else {
            UIView.showWarningMessage(title: "Warning", message: "Something went wrong with your payment. Please contract our customer care.")
        }
    }
    
    
}
