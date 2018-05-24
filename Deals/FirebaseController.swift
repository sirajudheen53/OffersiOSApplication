//
//  FirebaseController.swift
//  Deals
//
//  Created by qbuser on 24/05/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import Firebase

class FirebaseController: NSObject {
    
    fileprivate class func firebaseDB() -> Firestore {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }
    
    class func fetchAllContentsFromCollection(_ collectionName : String, onCompletion : @escaping ((NSArray?, Error?)->())) {
        FirebaseController.firebaseDB().collection(collectionName).getDocuments() { (querySnapshot, err) in
            if let err = err {
                onCompletion(nil, err)
            } else {
                onCompletion(querySnapshot!.documents as NSArray, nil)
            }
        }
    }
    
    class func addDocumentToCollection(_ collectionName : String, document : [String : Any], onCompletion : @escaping ((DocumentReference?, Error?)->())) {
        var ref: DocumentReference? = nil
        ref = FirebaseController.firebaseDB().collection(collectionName).addDocument(data: document) { err in
            if let err = err {
                onCompletion(nil, err)
            } else {
                onCompletion(ref, nil)
            }
        }
    }
}
