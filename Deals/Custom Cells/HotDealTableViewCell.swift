//
//  HotDealTableViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 21/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class HotDealTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var hotDealTitleLabel: UILabel!
    @IBOutlet weak var dealInfoLabel: UILabel!
    
    var hotDeals : [Deal]?
    
    @IBOutlet weak var hotDealsListingCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()

        let nibName = UINib(nibName: "HotDealCollectionViewCell", bundle:nil)
        self.hotDealsListingCollectionView.register(nibName, forCellWithReuseIdentifier: "hotDealCell")
        self.hotDealTitleLabel.attributedText = self.hotDealTitleAttributedText(text: "Hot Today")
        self.dealInfoLabel.attributedText = self.dealInfoTitleAttributedText(text: "Walk in to your dream deals")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func customizeCell(hotDeals : [Deal]) {
        self.hotDeals = hotDeals
        self.hotDealsListingCollectionView.reloadData()
    }
    
    //MARK: - CollectionView Delegate Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let hotDeals = self.hotDeals {
            return hotDeals.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotDealCell", for: indexPath) as! HotDealCollectionViewCell
        cell.customizeCell(deal: self.hotDeals![indexPath.row])
        return cell
    }
    
    //MARK: - Private Methods
    
    func hotDealTitleAttributedText(text : String) -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font : Constants.boldProDisplayWithSize(size: 20.0),
                          NSAttributedStringKey.foregroundColor : Constants.onyxColor]
        let requiredString = NSMutableAttributedString(string: text, attributes: attributes)
        requiredString.addAttribute(NSAttributedStringKey.kern, value: 2.0, range: NSMakeRange(0, requiredString.length))
        return requiredString
    }
    
    func dealInfoTitleAttributedText(text : String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.7
        
        let attributes = [NSAttributedStringKey.font : Constants.regularFontWithSize(size: 14.0),
                          NSAttributedStringKey.paragraphStyle : paragraphStyle,
                          NSAttributedStringKey.foregroundColor : Constants.darkGrey]
        let requiredString = NSMutableAttributedString(string: text, attributes: attributes)
        return requiredString
    }
    
}
