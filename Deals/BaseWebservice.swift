//
//  BaseWebservice.swift
//  Deals
//
//  Created by Sirajudheen on 16/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import Alamofire

enum WebserviceFunction : String {
    case fetchDealsList = "deals/v2/all_deals"
    case login = "accounts/login"
    case addPhoneNumber = "accounts/add_phone_number"
    case verifyPhoneNumber = "accounts/verify_phone_number"
    case fetchUserProfile = "accounts/profile"
    case makeFavourite = "deals/wishlist"
    case makePurchase = "deals/purchase"
    case userView = "deals/user_view"
    case search = "deals/search"
    case registerToken = "accounts/device_register"
    case fetchDeal = "deals/deal"
    case checkInStock = "deals/deal/stock_available"
}

enum WebserviceMethod {
    case post
    case get
}

//let base_servive_url : String = "http://0.0.0.0:8000/"
//let image_service_url : String = "http://0.0.0.0:8000/"

//let base_servive_url : String = "http://192.168.1.12:8000/"
//let image_service_url : String = "http://192.168.1.124:8000/"

let image_service_url : String = "https://staging-api.godollardeals.com/"
let base_servive_url : String = "https://staging-api.godollardeals.com/"

//let image_service_url : String = "https://api.godollardeals.com/"
//let base_servive_url : String = "https://api.godollardeals.com/"


class BaseWebservice: NSObject {
    class func performRequest(function : WebserviceFunction, requestMethod : WebserviceMethod, params : [String : AnyObject]?, headers : [String : String]?, onCompletion completionBlock : @escaping ((_ response : Any?, _ error : Error?)->())) {
        
        let urlString = base_servive_url + function.rawValue
        
        if requestMethod == WebserviceMethod.get {
            Alamofire.request(urlString, method: .get, parameters: params, encoding: URLEncoding(arrayEncoding: .noBrackets), headers: headers).responseJSON {
                response in
                switch response.result {
                case .success:
                    completionBlock(response.value, nil)
                    break
                case .failure(let error):
                    print("Error - \(error.localizedDescription)")
                    completionBlock(nil, error)
                }
            }
        } else {
            Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
                response in
                switch response.result {
                case .success:
                    completionBlock(response.value, nil)
                    break
                case .failure(let error):
                    print("Error - \(error.localizedDescription)")
                    completionBlock(nil, error)
                }
            }
        }
    }
}
