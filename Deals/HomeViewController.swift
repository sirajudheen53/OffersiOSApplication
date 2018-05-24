//
//  HomeViewController.swift
//  Test
//
//  Created by qbuser on 16/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate {

    var availableDeals : [Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        self.title = "Home"
    
        if Auth.auth().currentUser?.uid != nil {
            FirebaseController.fetchAllContentsFromCollection("Deal", onCompletion: { (deals, error) in
                if error != nil {
                    
                } else {
                    FirebaseController.addDocumentToCollection("Purchase", document: ["userId" : Auth.auth().currentUser!.uid, "dealId" : deals!.first!.documentID], onCompletion: { (documentReference, error) in
                        print("deal purchased")
                    })
                }
            })
        } else {
            GIDSignIn.sharedInstance().signIn()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealListingCell", for: indexPath);
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailsView", sender: nil)
    }


}
