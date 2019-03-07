//
//  PhoneNumberInputViewController.swift
//  Deals
//
//  Created by Sirajudheen on 02/02/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit
import PhoneNumberKit
import SVProgressHUD

class PhoneNumberInputViewController: UIViewController, UIGestureRecognizerDelegate, CodeInputViewDelegate {

    enum InputTextFieldTag : Int {
        case phoneNumberFieldTag = 100
    }
    
    
    
    @IBOutlet weak var resentOTPButton: UIButton!
    @IBOutlet weak var attemptNumberLabel: UILabel!
    @IBOutlet weak var invalidOTPErrorMessagLabel: UILabel!
    @IBOutlet weak var codeInputView: UIView!
    @IBOutlet weak var inputViewVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberInputInfoTitle: UILabel!
    var currentUser : UserProfile?
    var phoneNumberChangeActionBlock : (()->())?
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var otpInputView: UIView!
    @IBOutlet weak var phoneNumberInputView: UIView!
    @IBOutlet weak var verificationCodeInputInfoLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    
    let phoneNumberKit = PhoneNumberKit()
    var _codeInputView : CodeInputView!
    var inputOTP = ""
    var numberOfOTPAttempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDoneAccessoryViewInTextField()
        addPrefixIconOnPhoneInputTextField()

        _codeInputView = CodeInputView(frame: codeInputView.frame)
        _codeInputView.delegate = self
        otpInputView.addSubview(_codeInputView)
        
        
        
        if let currentUser = User.getProfile(), let currentPhoneNumber = currentUser.phoneNumber, currentPhoneNumber != "" {
            phoneNumberInputInfoTitle.isHidden = true
            do {
                let parsedNumber = try phoneNumberKit.parse(currentPhoneNumber)
                phoneNumberTextField.text = "+\(parsedNumber.countryCode)" + "\(parsedNumber.nationalNumber)"
            }
            catch {
                phoneNumberTextField.text = currentPhoneNumber
                print("Generic parser error")
            }
        } else {
            phoneNumberTextField.text = "+\(phoneNumberKit.countryCode(for: phoneNumberTextField.defaultRegion) ?? 1)"
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
    
    @IBAction func resendButtonClicked(_ sender: Any) {
        doneWithNumberPad()
    }
    
    func verifyOTPWithServer() {
        guard let textFieldText = phoneNumberTextField.text else {
            errorMessageLabel.text = "Please enter a valid phone number"
            errorMessageLabel.isHidden = false
            return
        }
        
        var requiredNumber : String = "";
        do {
            let parsedNumber = try phoneNumberKit.parse(textFieldText)
            requiredNumber = "+\(parsedNumber.countryCode)" + "\(parsedNumber.nationalNumber)"
        }
        catch {
            print("Generic parser error")
        }
        
        if !requiredNumber.isPhoneNumber {
            errorMessageLabel.text = "Please enter a valid phone number"
            errorMessageLabel.isHidden = false
            return
        }
        
        
        if let serverToken = User.getProfile()?.token {
            SVProgressHUD.show()

            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            BaseWebservice.performRequest(function: .verifyPhoneNumber, requestMethod: .post, params: ["phone_number" :  requiredNumber as AnyObject, "otp" : inputOTP as AnyObject], headers: userProfileFetchHeader) { (response, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                }
                if let response = response as? [String : String] {
                    if response["status"] == "success" {
                        if let user = User.getProfile() {
                            user.phoneNumber = requiredNumber
                            user.saveToUserDefaults()
                            self.dismiss(animated: false, completion: self.phoneNumberChangeActionBlock)
                        }
                    } else if response["status"] == "failed" {
                        self.invalidOTPErrorMessagLabel.isHidden = false
                    }  else {
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
        
        guard let textFieldText = phoneNumberTextField.text else {
            errorMessageLabel.text = "Please enter a valid phone number"
            errorMessageLabel.isHidden = false
            return
        }
        
        var requiredNumber : String = "";
        do {
            let parsedNumber = try phoneNumberKit.parse(textFieldText)
            requiredNumber = "+\(parsedNumber.countryCode)" + "\(parsedNumber.nationalNumber)"
        }
        catch {
            print("Generic parser error")
        }
        
        if !requiredNumber.isPhoneNumber {
            errorMessageLabel.text = "Please enter a valid phone number"
            errorMessageLabel.isHidden = false
            return
        }
        
        self.view.endEditing(true)
        errorMessageLabel.isHidden = true
        
        if let serverToken = User.getProfile()?.token {
            SVProgressHUD.show()

            let userProfileFetchHeader = ["Authorization" : "Token \(serverToken)"]
            BaseWebservice.performRequest(function: .addPhoneNumber, requestMethod: .post, params: ["phone_number" : requiredNumber as AnyObject], headers: userProfileFetchHeader) { (response, error) in
                if let response = response as? [String : String] {
                    SVProgressHUD.dismiss()
                    if let error = error {
                        UIView.showWarningMessage(title: "Warning", message: error.localizedDescription)
                    }
                    if response["status"] == "success" {
                            if let formattedText = self.phoneNumberTextField.text {
                                self.verificationCodeInputInfoLabel.text = "Please enter verification code sent to\n\(formattedText)"
                            }
                            self.phoneNumberInputView.isHidden = true
                            self.otpInputView.isHidden = false
                            self._codeInputView.becomeFirstResponder()
                            self.numberOfOTPAttempts += 1
                        if self.numberOfOTPAttempts == 2 {
                            self.attemptNumberLabel.text = "1 Attempt remaining"
                        } else if self.numberOfOTPAttempts == 1 {
                            self.attemptNumberLabel.text = "2 Attempts remaining"
                        } else {
                            self.attemptNumberLabel.isHidden = true
                            self.resentOTPButton.isHidden = true
                        }
                        UIView.showSuccessMessage(title: "", message: "OTP Sent to your phone number")
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
        SVProgressHUD.dismiss()
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
    
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
        inputOTP = code
        verifyOTPWithServer()
    }

}

extension String {
    var isPhoneNumber: Bool {
        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
}

