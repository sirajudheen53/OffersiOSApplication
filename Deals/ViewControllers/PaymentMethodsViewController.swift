//
//  PaymentMethodsViewController.swift
//  Deals
//
//  Created by NewUser on 25/06/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit
import SVProgressHUD
import QpayPayment

class PaymentMethodsViewController: UIViewController, QPRequestProtocol {
    
    enum PaymentType {
        case cash
        case online
    }

    @IBOutlet weak var discalimerLabel: UILabel!
    @IBOutlet weak var payInCashButton: UIButton!
    @IBOutlet weak var payOnlineButton: UIButton!
    
    var qpRequestParams : QPRequestParameters!
    var deal : Deal?
    
    var dealNotInStockNotifier : (()->())?
    var dealPurchaseNotifier : ((_ response : Any?, _ error : Error?)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        qpRequestParams =   QPRequestParameters(viewController: self)
        qpRequestParams.delegate = self
        
        if let user = User.getProfile() {
            if user.remainingCODCount == 0 {
                disablePayInCashButton()
                discalimerLabel.text = "You are temporarily banned from using ‘Pay In Cash’ option as \(user.missedCODCount) of the previously purchased pay at outlet coupons got expired or not redeemed yet. Please contact support for help."
                discalimerLabel.textColor = Constants.redColor
            } else if user.missedCODCount > 0 {
                payInCashButton.isEnabled = true
                discalimerLabel.text = "You may avail ‘Pay In Cash’ option \(user.remainingCODCount) more times only, as \(user.missedCODCount) previously purchased pay at outlet coupons got expired or not redeemed yet."
                discalimerLabel.font = Constants.mediumFontWithSize(size: 14)
                discalimerLabel.textColor = Constants.redColor
            }
        }
        
        if let deal = deal {
            if !deal.isCodAvailable {
                discalimerLabel.isHidden = true
                disablePayInCashButton()
                payInCashButton.setTitle("Pay In Cash is not available", for: .normal)
            }
        }
    }
    
    func disablePayInCashButton() {
        payInCashButton.alpha = 0.3
        payInCashButton.isEnabled = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IBAction Methods
    
    func initiatePayment() {
        qpRequestParams.gatewayId = "017824682"
        qpRequestParams.secretKey = "2-ZLCwqYdo+zE+hS"
        qpRequestParams.name = "Dollar Deals"
        qpRequestParams.address = "Dollar Deals - Qatar"
        qpRequestParams.city = "Doha"
        qpRequestParams.state = "Doha"
        qpRequestParams.country  = "QA"
        qpRequestParams.email = User.getProfile()?.email ?? "info@godollardeals.com"
        qpRequestParams.currency = "QAR"
        qpRequestParams.referenceId = UUID().uuidString
        qpRequestParams.phone = "\(User.getProfile()?.phoneNumber ?? "")"
        qpRequestParams.amount = Double(deal?.dealPrice ?? 1) //any float value
        qpRequestParams.mode = "live"
        qpRequestParams.productDescription = "A Deal from Dollar Deals"
        qpRequestParams.sendRequest()
    }
    
    func checkStockAvailabilityWithServer(paymentType : PaymentType) {
        SVProgressHUD.show()
        
        if let serverToken = User.getProfile()?.token {
            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            if let deal = deal {
                let params = ["deal_id" : deal.dealId as AnyObject];
                
                BaseWebservice.performRequest(function: .checkInStock, requestMethod: .get, params: params, headers: userProfileFetchHeader) { (response, error) in
                    
                    if let error = error {
                        SVProgressHUD.dismiss()

                        UIView.showWarningMessage(title: "Sorry !!!", message: error.localizedDescription)
                    } else if let response = response as? [String : Any?] {
                        if response["status"] as? String == "success" {
                            if response["in_stock"] as? Bool == true {
                                if paymentType == .cash {
                                    self.makePurchase(orderId: UUID().uuidString, transactionId: nil)
                                } else {
                                    SVProgressHUD.dismiss()

                                    self.initiatePayment()
                                }
                            } else {
                                SVProgressHUD.dismiss()

                                if let dealNotInStockNotifier = self.dealNotInStockNotifier {
                                    dealNotInStockNotifier()
                                }
                            }
                            
                        } else if let message = response["message"] as? String {
                            SVProgressHUD.dismiss()

                            UIView.showWarningMessage(title: "Oops !", message: message)
                        }  else {
                            SVProgressHUD.dismiss()

                            UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                        }
                    } else {
                        SVProgressHUD.dismiss()

                        UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
                    }
                }
            }}
    }
    
    func showCODConfirmationAlert() {
        let alertController = UIAlertController(title: "Dollar Deals", message: "Pay in Cash option agrees that you need to pay \(deal?.dealPrice ?? 0) QAR with \(deal?.vendor?.name ?? "-") in their location. Do you need to continue ?", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Continue", style: .default) { (_) -> Void in
            if let deal = self.deal, deal.isCodAvailed {
                UIView.showWarningMessage(title: "Sorry", message: "You can only use one Pay In Cash for a deal. Please try with online payment")
            } else {
                self.checkStockAvailabilityWithServer(paymentType: .cash)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func payInCashButtonClicked(_ sender: Any) {
        showCODConfirmationAlert()
    }
   
    @IBAction func payOnlineButtonClicked(_ sender: Any) {
        checkStockAvailabilityWithServer(paymentType: .online)
    }
    
    func makePurchase(orderId : Any, transactionId : Any?) {
        if let serverToken = User.getProfile()?.token {
            guard let userPhoneNumber = User.getProfile()?.phoneNumber, userPhoneNumber != "" else {
                self.performSegue(withIdentifier: "showPhoneNumberInput", sender: nil)
                return
            }
            SVProgressHUD.show()
            let header = ["Authorization" : "Token \(serverToken)"]
            
            var params = ["deal_id" : deal!.dealId as AnyObject];
            params["order_id"] = orderId as AnyObject
            if let transactionId = transactionId {
                params["transaction_id"] = transactionId as AnyObject
            }
            
            BaseWebservice.performRequest(function: .makePurchase, requestMethod: .post, params: params, headers: header, onCompletion: { (response, error) in
                SVProgressHUD.dismiss()
                self.handlePurchaseResponse(response: response, error: error)

                
            })
        } else {
            self.performSegue(withIdentifier: "showLoginPopup", sender: nil)
        }
    }
    
    func handlePurchaseResponse(response : Any?, error : Error?) {
        if let error = error {
            UIView.showWarningMessage(title: "Sorry !!!", message: error.localizedDescription)
        } else if let response = response as? [String : Any?] {
            if response["status"] as? String == "success" {
                if let purchaseNotifier = self.dealPurchaseNotifier {
                    purchaseNotifier(response, error)
                    self.dismiss(animated: false, completion: nil);
                }
            } else if let message = response["message"] as? String {
                UIView.showWarningMessage(title: "Oops !", message: message)
            } else {
                UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
            }
        } else {
            UIView.showWarningMessage(title: "Sorry !!!", message: "Something went wrong with server. Please try after sometime")
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
}
