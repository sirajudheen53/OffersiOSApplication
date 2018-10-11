//
//  Purchase.swift
//  Deals
//
//  Created by Sirajudheen on 10/08/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class Purchase: NSObject {
    var deal : Deal?
    var purchaseDate : Date?
    var expiryDate : Date?
    var isRedeemed : Bool?
    var code : String?
    
    class func purchaseObjectFromProperties(properties : [String : Any]) -> Purchase {
        let requiredPurchaseObject = Purchase()
        if let dealProperties = properties["deal"] as? [String : Any] {
            requiredPurchaseObject.deal = Deal.dealObjectFromProperty(property: dealProperties)
        }
        if let purchaseDate = properties["purchase_date"] as? Double {
            requiredPurchaseObject.purchaseDate = Date(timeIntervalSince1970: purchaseDate)
        }
        if let expiryDate = properties["expiry_date"] as? Double {
            requiredPurchaseObject.expiryDate = Date(timeIntervalSince1970: expiryDate)
        }
        if let isRedeemed = properties["isRedeemed"] as? Bool {
            requiredPurchaseObject.isRedeemed = isRedeemed
        }
        if let code = properties["code"] as? String {
            requiredPurchaseObject.code = code
        }
        return requiredPurchaseObject
    }
    
    class func purchaseObjectsFromProperties(properties : [[String : Any]]) -> [Purchase] {
        var requiredPurchasesArray = [Purchase]()
        for singlePurchaseProperty in properties {
            requiredPurchasesArray.append(Purchase.purchaseObjectFromProperties(properties: singlePurchaseProperty))
        }
        return requiredPurchasesArray
    }
}
