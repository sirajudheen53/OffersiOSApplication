//
//  RoundedView.swift
//  Deals
//
//  Created by Sirajudheen on 19/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.topLeft, .topRight], radius: 20)
    }

}
