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
    var dealId : Int?
    var title : String?
    var dealPrice : Int?
    var originalPrice : Int?
    var numberOfPeopleBought : Int?
    var numberOfPeopleViewed : Int?
    var startDate : Date?
    var endDate : Date?
    var dealDescription: String?
    var vendor : Vendor?
    var category : Category?
    
    static func dealObjectFromProperty(property : [String : Any]) -> Deal {
        let requiredDeal = Deal()
        requiredDeal.title = property["title"] as? String
        requiredDeal.dealId = property["id"] as? Int
        requiredDeal.dealPrice = property["deal_price"] as? Int
        requiredDeal.originalPrice = property["original_price"] as? Int
        requiredDeal.numberOfPeopleBought = property["nubmer_of_peoples_bought"] as? Int
        requiredDeal.numberOfPeopleViewed = property["number_of_peoples_viewed"] as? Int
        requiredDeal.dealDescription = property["description"] as? String
        if let startDate = property["start_date"] as? String {
            requiredDeal.startDate = Date(fromString: startDate, format: DateFormatType.isoDateTime)
        }
        if let endDate = property["end_date"] as? String {
            requiredDeal.endDate = Date(fromString: endDate, format: DateFormatType.isoDateTime)
        }
        if let vendor = property["vendor"] as? [String : Any] {
            requiredDeal.vendor = Vendor.vendorObjectFromProperty(property: vendor)

        }
        if let category = property["category"] as? [String : Any] {
            requiredDeal.category = Category.categoryObjectFromProperty(property: category)
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
