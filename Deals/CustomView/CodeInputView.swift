//
//  CodeInputView.swift
//  Deals
//
//  Created by Sirajudheen on 12/02/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit

open class CodeInputView: UIView, UIKeyInput {
    open var delegate: CodeInputViewDelegate?
    private var nextTag = 1
    
    // MARK: - UIResponder
    
    open override var canBecomeFirstResponder : Bool {
        return true
    }
    
    // MARK: - UIView
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add six digitLabels
        var frame = CGRect(x: 15, y: 10, width: 20, height: 40)
        for index in 1...4 {
            let digitLabel = UILabel(frame: frame)
            digitLabel.font = Constants.regularFontWithSize(size: 30)
            digitLabel.tag = index
            digitLabel.text = "–"
            digitLabel.textAlignment = .center
            addSubview(digitLabel)
            frame.origin.x += 20 + 15
        }
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") } // NSCoding
    
    // MARK: - UIKeyInput
    
    public var hasText : Bool {
        return nextTag > 1 ? true : false
    }
    
    open func insertText(_ text: String) {
        if nextTag < 5 {
            (viewWithTag(nextTag)! as! UILabel).text = text
            nextTag += 1
            
            if nextTag == 5 {
                var code = ""
                for index in 1..<nextTag {
                    code += (viewWithTag(index)! as! UILabel).text!
                }
                delegate?.codeInputView(self, didFinishWithCode: code)
            }
        }
    }
    
    open func deleteBackward() {
        if nextTag > 1 {
            nextTag -= 1
            (viewWithTag(nextTag)! as! UILabel).text = "–"
        }
    }
    
    open func clear() {
        while nextTag > 1 {
            deleteBackward()
        }
    }
    
    // MARK: - UITextInputTraits
    
    open var keyboardType: UIKeyboardType { get { return .numberPad } set { } }
}

public protocol CodeInputViewDelegate {
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String)
}
