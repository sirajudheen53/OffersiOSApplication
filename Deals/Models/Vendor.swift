//
//  Vendor.swift
//  Deals
//
//  Created by Sirajudheen on 17/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class Vendor: NSObject {
    var vendorId : Int?
    var name : String?
    var locationLat : Double?
    var locationLong : Double?
    var address : String?
    
    static func vendorObjectFromProperty(property : [String : Any]) -> Vendor {
        let requiredVendor = Vendor()
        requiredVendor.vendorId = property["id"] as? Int
        requiredVendor.name = property["name"] as? String
        requiredVendor.locationLat = property["location_lat"] as? Double
        requiredVendor.locationLong = property["location_long"] as? Double
        requiredVendor.address = property["address"] as? String
        return requiredVendor
    }
}
