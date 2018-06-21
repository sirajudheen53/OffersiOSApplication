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
    case fetchDealsList = "deals/all_deals"
}

enum WebserviceMethod {
    case post
    case get
}

let base_servive_url : String = "http://127.0.0.1:8000/"

class BaseWebservice: NSObject {
    class func performRequest(function : WebserviceFunction, requestMethod : WebserviceMethod, params : [String : AnyObject]?, headers : [String : String]?, onCompletion completionBlock : @escaping ((_ response : Any?, _ error : Error?)->())) {
        
        let urlString = base_servive_url + function.rawValue
        
        if requestMethod == WebserviceMethod.get {
            Alamofire.request(urlString, method: .get, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
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
