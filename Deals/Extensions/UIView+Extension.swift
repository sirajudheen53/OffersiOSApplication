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
    
    static func showSuccessMessage(title : String, message : String) {
        let view: MessageView = try! SwiftMessages.viewFromNib()
        view.configureContent(title: title, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: { _ in SwiftMessages.hide() })
        view.configureTheme(.success, iconStyle: .default)
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
    
    class func createQRFromString(_ str: String, size: CGSize) -> UIImage {
        let stringData = str.data(using: .utf8)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        
        let minimalQRimage = qrFilter.outputImage!
        // NOTE that a QR code is always square, so minimalQRimage..width === .height
        let minimalSideLength = minimalQRimage.extent.width
        
        let smallestOutputExtent = (size.width < size.height) ? size.width : size.height
        let scaleFactor = smallestOutputExtent / minimalSideLength
        let scaledImage = minimalQRimage.transformed(
            by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        return UIImage(ciImage: scaledImage,
                       scale: UIScreen.main.scale,
                       orientation: .up)
    }
}
