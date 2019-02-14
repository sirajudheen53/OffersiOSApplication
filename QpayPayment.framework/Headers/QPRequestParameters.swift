//
//  QPRequestParameters.swift
//  QpayPayment
//
//  Created by Amit on 16/08/17.
//  Copyright © 2017 Nexxuspg. All rights reserved.
//

import Foundation

@objc public protocol QPRequestProtocol {
    func qpResponse(_ response:NSDictionary)
}


@objc public class QPRequestParameters:NSObject
{
    @objc public var gatewayId: String!
    @objc public var name: String!
    @objc public var address: String!
    @objc public var city: String!
    @objc public var state: String!
    @objc public var country: String!
    @objc public var email: String!
    @objc public var currency: String!
    @objc public var referenceId: String!
    @objc public var phone: String!
    @objc public var amount: Double = 0.0
    @objc public var mode: String!
    @objc public var productDescription: String!
    @objc public var secretKey: String!
    var token: String!
    var action: String!
    var signature: String!
    var signatureFields: String!
    var source: String!

    var parentViewController:UIViewController!
    @objc public var delegate:QPRequestProtocol?

    
    @objc public init(viewController: UIViewController!)
    {
        self.parentViewController = viewController
        self.action = "capture"
        self.token = "true"
        self.source = "mobilesdk"
        self.signatureFields = "gatewayId,amount,referenceId"
    }
    
    @objc public func sendRequest() {
        let request = QPPaymentRequest(params: self)
        request.sendPaymentRequest()
    }
    
}

