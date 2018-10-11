//
//  DealDetailsViewController.swift
//  Test
//
//  Created by qbuser on 21/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreGraphics
class DealDetailsViewController: UIViewController {

    var deal : Deal?
    var dealCode : String?
    
    @IBOutlet weak var phoneContactButton: UIButton!
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var originalPriceValuLabel: UILabel!
    @IBOutlet weak var offerPriceValueLabel: UILabel!
    @IBOutlet weak var validUptoValueLabel: UILabel!
    @IBOutlet weak var vendorAddressValueLabel: UILabel!
    @IBOutlet weak var numberOfPeopleViewedValueLabel: UILabel!
    @IBOutlet weak var numberOfPeoplePurchased: UILabel!
    @IBOutlet weak var viewsTitleLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    
    @IBOutlet weak var offerPercentageStripLabel: UILabel!
    @IBOutlet weak var offerDetailsView: UIView!
    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var dealDetailsButton: UIButton!
    
    @IBOutlet weak var purchasesTitleLabel: UILabel!
    
    @IBOutlet weak var couponVendorAddressLabel: UILabel!
    @IBOutlet weak var couponDistanceValueLabel: UILabel!
    @IBOutlet weak var couponQRCodeImageView: UIImageView!
    @IBOutlet weak var couponCodeLabelView: UILabel!
    @IBOutlet weak var couponExpiresValueLabel: UILabel!
    @IBOutlet weak var dealInfoView: UIView!
    
    @IBOutlet weak var coupnInfoView: UIView!
    let conditionsArray = ["1 Voucher Valid for 1 person only", "Print/ SMS/ In-App voucher can be used to avail the deal", "Prior reservation recommneded (Upon purchase, you will receive a voucher with the reservation number)", "Timings: 12:30 PM to 3:30 PM Monday to Friday", "Prices are inclusive of all tax and other service charges", "Food images are for representation purpose only", "Voucher codes in one transaction must be used in 1 visit. For seperate use, seperate transactions must be made"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true
        self.navigationController?.isNavigationBarHidden = true

        self.configureUIElements()
        self.title = "Details"
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.7
        
        let attributes = [NSAttributedStringKey.font : Constants.compactTextRegulaFontWithSize(size: 14.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.lightDarkColor]
        let requiredString = NSAttributedString(string: address, attributes: attributes)
        return requiredString
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
                
            }
        }
        self.numberOfPeoplePurchased.text = "\(self.deal!.numberOfPeopleBought!)"
        self.vendorAddressValueLabel.text = self.deal!.vendor!.address
        self.offerTitleLabel.attributedText = self.titleAttributedText(title: self.deal!.dealDescription!)
        self.dealDetailsButton.setAttributedTitle(self.moreDetailsAttributedText(title: "More Details"), for: UIControlState.normal)
        self.purchasesTitleLabel.attributedText = self.purchaseBoughtAttributedText(text: "PURCHASES")
        self.viewsTitleLabel.attributedText = self.purchaseBoughtAttributedText(text: "VIEWS")
        self.phoneContactButton.setAttributedTitle(self.contactTitleAttributedText(text: "Contact"), for: UIControlState.normal)
        self.validUptoValueLabel.attributedText = self.validUptoAttributedText(validUptoDate: "29 June 2018")
        
        let offerPercent : Double = (Double(self.deal!.dealPrice!)/Double(self.deal!.originalPrice!)*100)
        self.offerPercentageStripLabel.attributedText = offerPercentageStripValueAttributedString(value: "\(Int(offerPercent)) % off")
        
        self.phoneContactButton.layer.borderColor = Constants.darkGrey.cgColor
        self.phoneContactButton.layer.borderWidth = 1.0
        self.phoneContactButton.layer.cornerRadius = 4.0
        self.phoneContactButton.clipsToBounds = true
        
        
        
        
    }
    
    func showDealCodeView() {
        self.couponCodeLabelView.text = "DER7u"
        self.couponVendorAddressLabel.text = self.deal!.vendor!.address
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func buyNowButtonClicked(_ sender: UIButton) {
        if let serverToken = User.getProfile()?.token {
            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
                BaseWebservice.performRequest(function: .makePurchase, requestMethod: .post, params: ["deal_id" : deal!.dealId! as AnyObject], headers: userProfileFetchHeader, onCompletion: { (response, error) in
                    if let error = error {
                        //Handle Error
                    } else if let response = response as? [String : Any?] {
                        if response["status"] as? String == "success" {
                            NotificationCenter.default.post(Notification.init(name: Notification.Name("userProfileUpdated")))

                        } else {
                            //Handle Error
                        }
                    } else {
                        //Handle Error
                    }
                })
        } else {
            //Handle Error for no token found
            
        }
    }
    
    @IBAction func moreDetailsButtonClicked(_ sender: Any) {
    }
    
    @IBAction func contactButtonClicked(_ sender: Any) {
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
    }
    
    @IBAction func makeFavouriteButtonClicked(_ sender: Any) {
    }
    
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
//    // MARK: - TableView Delegate Methods
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return conditionsArray.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "conditionsListCell", for: indexPath) as! ConditionsListingTableViewCell
//        cell.conditionTextLabel.text = conditionsArray[indexPath.row]
//        cell.indexNumberLabel.text = "\(indexPath.row+1)"
//        return cell
//    }
//
//

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
