//
//  DealFeature.swift
//  Deals
//
//  Created by Sirajudheen on 23/02/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit

class DealFeature: NSObject {
    var featureTitle = ""
    var featureDescription = ""
    
    static func dealFeatureWithProperties(properties : [String : String]) -> DealFeature {
        let requiredFeature = DealFeature()
        requiredFeature.featureTitle = properties["title"] ?? "";
        requiredFeature.featureDescription = properties["description"] ?? "";
        return requiredFeature
    }
    
    static func dealFeaturesFromProperties(arrayOfProperties : [[String : String]]) -> [DealFeature] {
        var requiredFeatures = [DealFeature]()
        for properties in arrayOfProperties {
            requiredFeatures.append(DealFeature.dealFeatureWithProperties(properties: properties))
        }
        return requiredFeatures
    }
}
