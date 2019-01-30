//
//  BaseViewController.swift
//  Deals
//
//  Created by Sirajudheen on 30/01/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class BaseViewController: UIViewController {
    var analyticsScreenName = "BaseView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = User.getProfile()?.token, let firstName = User.getProfile()?.firstName, let lastName = User.getProfile()?.lastName {
            Analytics.setUserID(firstName + " " + lastName)
        } else {
            Analytics.setUserID("Anonymous")
        }
        Analytics.setScreenName(self.analyticsScreenName, screenClass: String(describing: self.otherTypeName))
    }
    
    
        
        // Instance Level - Alternative Way
        var otherTypeName: String {
            let thisType = type(of: self)
            return String(describing: thisType)
        }
        
        // Type Level
        static var typeName: String {
            return String(describing: self)
        }
        
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
