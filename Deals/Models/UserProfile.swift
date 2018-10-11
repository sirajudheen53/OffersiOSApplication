//
//  UserProfile.swift
//  Deals
//
//  Created by Sirajudheen on 21/07/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class UserProfile: User {
    var wishList : [Deal]?
    var purchases : [Purchase]?
    
    class func userProfileWithProperties(properties : [String : Any]) -> UserProfile {
        let requiredUserProfile = UserProfile()
        if let token = properties["token"] as? String {
            requiredUserProfile.token = token
        }
        if let firstName = properties["first_name"] as? String  {
            requiredUserProfile.firstName = firstName
        }
        if let lastName = properties["last_name"] as? String  {
            requiredUserProfile.lastName = lastName
        }
        if let email = properties["email"] as? String  {
            requiredUserProfile.email = email
        }
        if let photo = properties["photo"] as? String  {
            requiredUserProfile.photo = photo
        }
        if let provider = properties["provider"] as? String  {
            requiredUserProfile.provider = provider
        }
        if let phoneNumber = properties["phone_number"] as? String  {
            requiredUserProfile.phoneNumber = phoneNumber
        }
        if let wishlistProperties = properties["wishlist"] as? [[String : Any]] {
            requiredUserProfile.wishList = Deal.dealObjectsFromProperties(properties: wishlistProperties)
        }
        if let purchaseItemsProperties = properties["purchases"] as? [[String : Any]] {
            requiredUserProfile.purchases = Purchase.purchaseObjectsFromProperties(properties: purchaseItemsProperties)
        }
        return requiredUserProfile
    }
}
