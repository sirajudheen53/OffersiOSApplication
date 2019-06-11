//
//  FeedbackViewController.swift
//  Deals
//
//  Created by Sirajudheen on 26/01/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackViewController: BaseViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    override func viewDidLoad() {
        analyticsScreenName = "Feedback View"

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func emailButtonClicked(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            UIView.showWarningMessage(title: "Sorry !!!", message: "Could not send email from your phone")

        }
    }
    
    @IBAction func backgroundButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func phoneButtonClicked(_ sender: Any) {
        if let url = URL(string: "tel://+97444430780)"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["info@godollardeals.com"])
        
        var version = "-"
        if let shortBundleVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            version = shortBundleVersion
        }

        mailComposerVC.setSubject("Feedback - Dollar Deals iOS - \(version)")
        mailComposerVC.setMessageBody("Hi Dollar Deals,", isHTML: false)
        
        return mailComposerVC
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
