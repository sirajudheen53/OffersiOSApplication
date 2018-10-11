//
//  HomeExploreTableViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 06/07/18.
//  Copyright © 2018 qbuser. All rights reserved.
//

import UIKit

let categoriesImagesList = ["beauty", "carcare", "entertainment", "health", "reatail", "restaurent", "services", "travel"]
let categoriesTitleList = ["Beauty", "Car Care", "Entertainment", "Health", "Retail", "Restaurent", "Services", "Travel"]

class HomeExploreTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var exploreCollectionViewCell: UICollectionView!
    var exploreCategorySelectionBlock : ((_ category : FilterCategories)->())?

    override func awakeFromNib() {
        super.awakeFromNib()

       let exploreNib = UINib(nibName: "HomeExploreCollectionViewCell", bundle: nil)
        exploreCollectionViewCell.register(exploreNib, forCellWithReuseIdentifier: "exploreCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - UICollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exploreCollectionViewCell", for: indexPath) as! HomeExploreCollectionViewCell
        print(categoriesImagesList[indexPath.row])
        cell.customizeCell(image: UIImage(named: categoriesImagesList[indexPath.row])!, title: categoriesTitleList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.exploreCategorySelectionBlock!(.Beauty)
        case 1:
            self.exploreCategorySelectionBlock!(.CarCare)
        case 2:
            self.exploreCategorySelectionBlock!(.Entertainment)
        case 3:
            self.exploreCategorySelectionBlock!(.Health)
        case 4:
            self.exploreCategorySelectionBlock!(.Retail)
        case 5:
            self.exploreCategorySelectionBlock!(.Restaurent)
        case 6:
            self.exploreCategorySelectionBlock!(.Services)
        case 7:
            self.exploreCategorySelectionBlock!(.Travel)
        default:
            self.exploreCategorySelectionBlock!(.Travel)
        }
    }
    
}
