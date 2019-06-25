//
//  Deal.swift
//  Deals
//
//  Created by Sirajudheen on 17/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import AFDateHelper

class Deal: NSObject {
    var dealId : Int = 0
    var title : String = ""
    var dealPrice : Int = 0
    var originalPrice : Int = 0
    var numberOfPeopleBought : Int = 0
    var numberOfPeopleViewed : Int = 0
    var startDate : Date = Date()
    var purchasedDate : Date?
    var endDate : Date = Date()
    var dealDescription: String = ""
    var vendor : Vendor?
    var category : Category?
    var images : [String]?
    var isFavourited : Bool = false
    var currencySymbol : String = ""
    var purchaseCode : String = ""
    var purchaseExpiry : Date = Date()
    var numberOfPurchases : Int = 0
    var isRedeemed : Bool = false
    var allowedSimultaneous : Int = 1
    var maximum_count : Int = 0
    var conditons = [String]()
    var features = [DealFeature]()
    var isCodAvailable : Bool = false
    
    static func dealObjectFromProperty(property : [String : Any]) -> Deal {
        print(property);
        let requiredDeal = Deal()
        requiredDeal.title = property["title"] as? String ?? ""
        requiredDeal.dealId = property["id"] as? Int ?? 0
        requiredDeal.dealPrice = property["deal_price"] as? Int ?? 0
        requiredDeal.originalPrice = property["original_price"] as? Int ?? 0
        requiredDeal.maximum_count = property["maximum_count"] as? Int ?? 0
        if let purchasedDate = property["purchased_date"] as? String {
            requiredDeal.purchasedDate = Date(fromString: purchasedDate, format: DateFormatType.isoDateTime) ?? Date()
        }
        requiredDeal.numberOfPeopleBought = property["nubmer_of_peoples_bought"] as? Int ?? 0
        requiredDeal.numberOfPeopleViewed = property["number_of_peoples_viewed"] as? Int ?? 0
        requiredDeal.allowedSimultaneous = property["number_of_simultaneous_purchase"] as? Int ?? 1
        requiredDeal.dealDescription = property["description"] as? String ?? ""
        if let startDate = property["start_date"] as? Double {
            requiredDeal.startDate = Date(timeIntervalSince1970: startDate)
        }
        if let endDate = property["end_date"] as? Double {
            requiredDeal.endDate = Date(timeIntervalSince1970: endDate)
        }
        if let vendor = property["vendor"] as? [String : Any] {
            requiredDeal.vendor = Vendor.vendorObjectFromProperty(property: vendor)

        }
        if let category = property["category"] as? [String : Any] {
            requiredDeal.category = Category.categoryObjectFromProperty(property: category)
        }
        if let images = property["images"] as? [String] {
            requiredDeal.images = images
        }
        if let isFavourite = property["is_favoured"] as? Bool {
            requiredDeal.isFavourited = isFavourite
        }
        if let currencySymbol = property["currency_symbol"] as? String {
            requiredDeal.currencySymbol = currencySymbol
        }
        if let conditions = property["conditions"] as? [String] {
            requiredDeal.conditons = conditions
        }
        if let features = property["features"] as? [[String : String]] {
            requiredDeal.features = DealFeature.dealFeaturesFromProperties(arrayOfProperties: features)
        }
        if let recentPurchases = property["recent_purchase"] as? [String : Any] {
            if let code = recentPurchases["code"] as? String {
                requiredDeal.purchaseCode = code
            }
            if let purchaseDate = recentPurchases["purchase_date"] as? Double {
                requiredDeal.purchasedDate = Date(timeIntervalSince1970: purchaseDate)
            }
            if let purchaseExpiryDate = recentPurchases["expiry_date"] as? Double {
                requiredDeal.purchaseExpiry = Date(timeIntervalSince1970: purchaseExpiryDate)
            }
            if let isRedeemed = recentPurchases["isRedeemed"] as? Bool {
                requiredDeal.isRedeemed = isRedeemed
            }
            if let purchasesCount = recentPurchases["purchase_count"] as? Int {
                requiredDeal.numberOfPurchases = purchasesCount
            }
        }
        if let isCodAvailable = property["is_cod_available"] as? Bool {
            requiredDeal.isCodAvailable = isCodAvailable
        }
        return requiredDeal
    }
    
    static func dealObjectsFromProperties(properties : [[String : Any]]) -> [Deal] {
       var requiredDeals = [Deal]()
        for dealProperty in properties {
            requiredDeals.append(Deal.dealObjectFromProperty(property: dealProperty))
        }
        return requiredDeals
    }
}
