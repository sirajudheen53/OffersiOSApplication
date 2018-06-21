//
//  Category.swift
//  Deals
//
//  Created by Sirajudheen on 17/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class Category: NSObject {
    var categoryId : Int?
    var name : String?
    
    static func categoryObjectFromProperty(property : [String : Any]) -> Category {
        let requiredCategory = Category()
        requiredCategory.categoryId = property["id"] as? Int
        requiredCategory.name = property["name"] as? String
        return requiredCategory
    }
}
