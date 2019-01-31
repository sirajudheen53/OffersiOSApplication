//
//  TermsViewController.swift
//  Deals
//
//  Created by Sirajudheen on 26/01/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: BaseViewController {
    @IBOutlet weak var termsWebView: WKWebView!
    var itemTitle = ""
    var itemFileName = ""
    override func viewDidLoad() {
        analyticsScreenName = "Terms And Conditions View"

        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.title = itemTitle
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")

        let htmlPath = Bundle.main.path(forResource: itemFileName, ofType: "html")
        let htmlUrl = URL(fileURLWithPath: htmlPath!, isDirectory: false)
        termsWebView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
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
