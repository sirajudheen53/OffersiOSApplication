//
//  Date+Extension.swift
//  Deals
//
//  Created by Sirajudheen on 31/12/17.
//  Copyright © 2017 qbuser. All rights reserved.
//

import UIKit

extension Date {
    func defaultStringFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM YYYY"
        return dateFormatter.string(from: self)
    }
}
