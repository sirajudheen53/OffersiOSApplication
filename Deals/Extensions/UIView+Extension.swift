//
//  UIView+Extension.swift
//  Deals
//
//  Created by Sirajudheen on 14/12/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import SwiftMessages

@IBDesignable extension UIView {
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    static func showWarningMessage(title : String, message : String) {
        let view: MessageView = try! SwiftMessages.viewFromNib()
        view.configureContent(title: title, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: { _ in SwiftMessages.hide() })
        view.configureTheme(.warning, iconStyle: .default)
        view.accessibilityPrefix = "warning"
        view.configureDropShadow()
        view.button?.isHidden = true
        view.iconImageView?.isHidden = true
        view.iconLabel?.isHidden = true
        
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: UIWindow.Level(2))
        config.duration = .seconds(seconds: 2)
        SwiftMessages.show(config: config, view: view)
    }
}
