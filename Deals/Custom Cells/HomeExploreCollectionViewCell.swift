//
//  HomeExploreCollectionViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 06/07/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

class HomeExploreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.categoryImageView.clipsToBounds = true
        self.categoryImageView.layer.cornerRadius = 6.0
    }
    
    func customizeCell(image : UIImage, title : String) {
        self.categoryImageView.image = image
        self.categoryNameLabel.text = title
    }

}
