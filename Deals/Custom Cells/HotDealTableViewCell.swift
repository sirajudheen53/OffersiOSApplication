//
//  HotDealTableViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 21/06/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit
import CoreLocation

class HotDealTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var hotDealTitleLabel: UILabel!
    @IBOutlet weak var dealInfoLabel: UILabel!
    @IBOutlet weak var dealNumbersInfoValueLabel: UILabel!
    
    var hotDeals : [Deal]?
    var makeFavouriteActionBlock : ((_ deal : Deal)->())?
    var hotDealsCellSelectionActionBlock : ((_ deal : Deal)->())?
    var currentUserLocation : CLLocation?

    @IBOutlet weak var topShadowDummyView: UIView!
    @IBOutlet weak var hotDealsListingCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()

        let nibName = UINib(nibName: "HotDealCollectionViewCell", bundle:nil)
        self.hotDealsListingCollectionView.register(nibName, forCellWithReuseIdentifier: "hotDealCell")
        self.dealInfoLabel.attributedText = self.dealInfoTitleAttributedText(text: "Walk in to your dream deals")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func customizeCell(hotDeals : [Deal]) {
        self.hotDeals = hotDeals
        self.hotDealsListingCollectionView.reloadData()
        self.dealNumbersInfoValueLabel.attributedText = self.dealNumbersInfoAttributedText(showingDealNumber: 1)
    }
    
    func dealNumbersInfoAttributedText(showingDealNumber : Int) -> NSAttributedString {
        let currentNumberAttributes = [NSAttributedStringKey.font : Constants.mediumFontWithSize(size: 20.0),
                                       NSAttributedStringKey.foregroundColor : Constants.mountainMedow]
        let totalDealNumbersAttributes = [NSAttributedStringKey.font : Constants.regularFontWithSize(size: 14.0),
                                          NSAttributedStringKey.foregroundColor : Constants.taupeyGrey]
        let currentNumberAttributedString = NSMutableAttributedString(string: "\(showingDealNumber)", attributes: currentNumberAttributes)
        let totalNumberAttributedString = NSAttributedString(string: "/\(self.hotDeals!.count)", attributes: totalDealNumbersAttributes)
        currentNumberAttributedString.append(totalNumberAttributedString)
        return currentNumberAttributedString
    }
    
    //MARK: - CollectionView Delegate Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let hotDeals = self.hotDeals {
            return hotDeals.count
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotDealCell", for: indexPath) as! HotDealCollectionViewCell
        if let hotDeals = hotDeals {
            cell.currentUserLocation = self.currentUserLocation
            cell.customizeCell(deal: hotDeals[indexPath.row])
            cell.makeFavouriteActionBlock = self.makeFavouriteActionBlock
        } else {
            cell.showLoadingAnimation()
        }
 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var showingNumber = indexPath.row
        if indexPath.row == 0 {
            showingNumber = 1
        } else if let hotDeals = self.hotDeals, indexPath.row == hotDeals.count-1  {
            showingNumber = hotDeals.count
        }
        if let _ = self.hotDeals {
            self.dealNumbersInfoValueLabel.attributedText = self.dealNumbersInfoAttributedText(showingDealNumber: showingNumber)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.hotDealsCellSelectionActionBlock!(self.hotDeals![indexPath.row])
    }
    
    //MARK: - Private Methods
    
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
