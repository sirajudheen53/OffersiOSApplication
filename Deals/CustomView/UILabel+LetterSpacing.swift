//
//  UILabel+LetterSpacing.swift
//  Deals
//
//  Created by Sirajudheen on 08/07/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

extension UILabel {
    
    @IBInspectable
    var letterSpace: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else {
                attributedString = NSMutableAttributedString(string: "")
                
            }
            
            attributedString.addAttribute(NSAttributedStringKey.kern,
                                          value: newValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
            
        }
        
        get {
            if let currentLetterSpace = attributedText?.attribute(NSAttributedStringKey.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            }
            else {
                return 0
            }
        }
    }
}
