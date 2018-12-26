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
    
    class func purchaseObjectFromProperties(properties : [String : Any]) -> Purchase {
        let requiredPurchaseObject = Purchase()
        if let dealProperties = properties["deal"] as? [String : Any] {
            requiredPurchaseObject.deal = Deal.dealObjectFromProperty(property: dealProperties)
        }
        if let purchaseDate = properties["purchase_date"] as? Double {
            requiredPurchaseObject.deal?.purchasedDate = Date(timeIntervalSince1970: purchaseDate)
        }
        if let expiryDate = properties["expiry_date"] as? Double {
            requiredPurchaseObject.deal?.purchaseExpiry = Date(timeIntervalSince1970: expiryDate)
        }
        if let isRedeemed = properties["isRedeemed"] as? Bool {
            requiredPurchaseObject.deal?.isRedeemed = isRedeemed
        }
        if let code = properties["code"] as? String {
            requiredPurchaseObject.deal?.purchaseCode = code
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
