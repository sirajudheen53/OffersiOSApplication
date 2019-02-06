//
//  PhoneNumberInputViewController.swift
//  Deals
//
//  Created by Sirajudheen on 02/02/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit
import SwiftPhoneNumberFormatter
import SVProgressHUD

class PhoneNumberInputViewController: UIViewController, UIGestureRecognizerDelegate {

    enum InputTextFieldTag : Int {
        case phoneNumberFieldTag = 100
        case firstOtpFieldTag = 101
        case secondOtpFieldTag = 102
        case thirdOtpFieldTag = 103
        case fourthOtpFieldTag = 104
    }
    
    @IBOutlet weak var inputViewVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberInputInfoTitle: UILabel!
    var currentUser : UserProfile?
    var phoneNumberChangeActionBlock : (()->())?
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var otpInputView: UIView!
    @IBOutlet weak var phoneNumberInputView: UIView!
    @IBOutlet weak var verificationCodeInputInfoLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: PhoneFormattedTextField!
    
    @IBOutlet weak var otpFourthField: UITextField!
    @IBOutlet weak var otpThirdTextField: UITextField!
    @IBOutlet weak var otpSecondTextField: UITextField!
    @IBOutlet weak var otpFirstTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otpFirstTextField.setBottomBorder()
        otpSecondTextField.setBottomBorder()
        otpThirdTextField.setBottomBorder()
        otpFourthField.setBottomBorder()
        addDoneAccessoryViewInTextField()
        addPrefixIconOnPhoneInputTextField()
       
        phoneNumberTextField.config.defaultConfiguration = PhoneFormat(defaultPhoneFormat: "(###) ###-##-##")

        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            phoneNumberTextField.prefix = "+\(getCorrespondingISDCode(countryCode: countryCode)) "
        } else {
            phoneNumberTextField.prefix = "+1 "
        }
        if let currentUser = currentUser, let  currentPhoneNumber = currentUser.phoneNumber, currentPhoneNumber != "" {
            phoneNumberInputInfoTitle.isHidden = true
            
            
            phoneNumberTextField.formattedText = currentPhoneNumber
        }
    }
    
    func addDoneAccessoryViewInTextField() {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneWithNumberPad))]
        numberToolbar.sizeToFit()
        phoneNumberTextField.inputAccessoryView = numberToolbar
 
    }
    
    @objc func cancelNumberPad() {
        self.view.endEditing(true)
    }
    
    @IBAction func otpFieldEditingChanged(_ sender: Any) {
        guard let textField = sender as? UITextField else {
            return
        }
        let text = textField.text
        
        if text?.utf16.count ?? 0 >= 1{
            switch textField{
            case otpFirstTextField:
                otpSecondTextField.becomeFirstResponder()
            case otpSecondTextField:
                otpThirdTextField.becomeFirstResponder()
            case otpThirdTextField:
                otpFourthField.becomeFirstResponder()
            case otpFourthField:
                verifyOTPWithServer()
            default:
                break
            }
        } else if text?.utf16.count ?? 0 == 0{
            switch textField{
            case otpFourthField:
                otpThirdTextField.becomeFirstResponder()
            case otpThirdTextField:
                otpSecondTextField.becomeFirstResponder()
            case otpSecondTextField:
                otpFirstTextField.becomeFirstResponder()
            case otpFirstTextField:
                return
            default:
                break
            }
        }
    }
    
    func verifyOTPWithServer() {
        guard let otp1 = otpFirstTextField.text, let otp2 = otpSecondTextField.text, let otp3 = otpThirdTextField.text, let otp4 = otpFourthField.text else {
            return
        }
        guard let phoneNumber = phoneNumberTextField.phoneNumber() else {
            return
        }
        
        let inputOTP = otp1 + otp2 + otp3 + otp4
        
        if let serverToken = User.getProfile()?.token {
            SVProgressHUD.show()

            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            BaseWebservice.performRequest(function: .verifyPhoneNumber, requestMethod: .post, params: ["phone_number" :  phoneNumber as AnyObject, "otp" : inputOTP as AnyObject], headers: userProfileFetchHeader) { (response, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                }
                if let response = response as? [String : String] {
                    if response["status"] == "success" {
                        if let user = User.getProfile() {
                            user.phoneNumber = phoneNumber
                            user.saveToUserDefaults()
                            self.dismiss(animated: false, completion: self.phoneNumberChangeActionBlock)
                        }
                    } else {
                        UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                } else {
                    UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                }
            }
        } else {
            self.performSegue(withIdentifier: "showLoginPopup", sender: nil)
        }
    }
    
    @objc func doneWithNumberPad() {
        guard let phoneNumber = phoneNumberTextField.phoneNumber(), phoneNumber.isPhoneNumber else {
            errorMessageLabel.text = "Please enter a valid phone number"
            errorMessageLabel.isHidden = false
            return
        }
        
        self.view.endEditing(true)
        errorMessageLabel.isHidden = true
        
        if let serverToken = User.getProfile()?.token {
            SVProgressHUD.show()

            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            BaseWebservice.performRequest(function: .addPhoneNumber, requestMethod: .post, params: ["phone_number" : phoneNumber as AnyObject], headers: userProfileFetchHeader) { (response, error) in
                if let response = response as? [String : String] {
                    SVProgressHUD.dismiss()
                    if let error = error {
                        UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                    }
                    if response["status"] == "success" {
                            if let formattedText = self.phoneNumberTextField.formattedText {
                                self.verificationCodeInputInfoLabel.text = "Please enter verification code sent to\n\(formattedText)"
                            }
                            self.phoneNumberInputView.isHidden = true
                            self.otpInputView.isHidden = false
                    } else {
                            UIView.showWarningMessage(title: "Warning", message: "Something went wrong with server. Please try after sometime")
                    }
                }
            }
        } else {
            self.performSegue(withIdentifier: "showLoginPopup", sender: nil)
        }    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

        
        let gestuerRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        gestuerRecognizer.delegate = self
        view.addGestureRecognizer(gestuerRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
 
    @objc func backgroundTapped() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            self.view.removeConstraint(inputViewVerticalCenterConstraint)
            self.view.addConstraint(inputViewBottomConstraint)
            inputViewBottomConstraint.constant = keyboardHeight + 50
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.removeConstraint(inputViewBottomConstraint)
        self.view.addConstraint(inputViewVerticalCenterConstraint)
    }
    
    func addPrefixIconOnPhoneInputTextField() {
        phoneNumberTextField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 20))
        let image = UIImage(named: "phone_number_input")
        imageView.image = image
        phoneNumberTextField.leftView = imageView
    }
    
    func getCorrespondingISDCode(countryCode : String) -> String {
        if let path = Bundle.main.path(forResource: "country_code", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String : Any] {
                    if let IsdCode = jsonResult[countryCode] as? String {
                        return IsdCode
                    }
                }
                    return ""
            } catch {
                return ""
            }
        }
        return ""
    }
    
    @IBAction func backgroundButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView != self.view {
            return false
        }
        return true
    }

}

extension PhoneNumberInputViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == InputTextFieldTag.phoneNumberFieldTag.rawValue {
            return
        }
        if let text = otpFirstTextField.text, text.utf16.count == 0 {
            otpFirstTextField.becomeFirstResponder()
        } else if let text = otpFirstTextField.text, text.utf16.count == 0 {
            otpSecondTextField.becomeFirstResponder()
        } else if let text = otpFirstTextField.text, text.utf16.count == 0 {
            otpThirdTextField.becomeFirstResponder()
        } else if let text = otpFirstTextField.text, text.utf16.count == 0 {
            otpFourthField.becomeFirstResponder()
        }
    }
}

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.characters.count && self.characters.count == 10
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
}

