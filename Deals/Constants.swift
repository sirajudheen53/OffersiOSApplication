//
//  Constants.swift
//  Deals
//
//  Created by Sirajudheen on 20/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class Constants: NSObject {
    // MARK: - Private Methods
    static let extraDarkColor = UIColor(displayP3Red: 55/255.0, green: 58/255.0, blue: 61/255.0, alpha: 1)
    static let blackDarkColor = UIColor(displayP3Red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    static let lightDarkColor = UIColor(displayP3Red: 97/255.0, green: 102/255.0, blue: 106/255.0, alpha: 1)
    static let darkColor = UIColor(displayP3Red: 97/255.0, green: 97/255.0, blue: 106/255.0, alpha: 1)
    static let darkGrey = UIColor(displayP3Red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1)
    static let extraGreyColor = UIColor(displayP3Red: 113/255.0, green: 118/255.0, blue: 122/255.0, alpha: 1)
    static let appliationGreyColor = UIColor(displayP3Red: 133/255.0, green: 133/255.0, blue: 133/255.0, alpha: 1)
    static let redColor = UIColor(displayP3Red: 248/255.0, green: 37/255.0, blue: 74/255.0, alpha: 1)
    static let dimGrey = UIColor(displayP3Red: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 1)
    static let onyxColor = UIColor(displayP3Red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1)
    
    class func mediumFontWithSize(size : CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Medium", size: size)!
    }
    
    class func lightFontWithSize(size : CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Light", size: size)!
    }
    
    class func semiBoldFontWithSize(size : CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Semibold", size: size)!
    }
    
    class func compactTextRegulaFontWithSize(size : CGFloat) -> UIFont {
        return UIFont(name: "SFCompactText-Regular", size: size)!
    }
    
    class func regularFontWithSize(size : CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Regular", size: size)!
    }
    
    class func boldProDisplayWithSize(size : CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Bold", size: size)!
    }
}
