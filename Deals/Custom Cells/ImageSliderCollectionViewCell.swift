//
//  ImageSliderCollectionViewCell.swift
//  Deals
//
//  Created by Sirajudheen on 17/03/19.
//  Copyright © 2019 qbuser. All rights reserved.
//

import UIKit

class ImageSliderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dealImageView: UIImageView!

    var imageUrl : String?
    
    func loadImage() {
        guard let imageUrlString = imageUrl else {
            return
        }
        
        self.dealImageView.af_setImage(withURL: URL(string: image_service_url + imageUrlString)!,
                                       placeholderImage: UIImage(named: "logo_small"),
                                       filter: nil,
                                       progress: nil,
                                       progressQueue: DispatchQueue.main,
                                       imageTransition: UIImageView.ImageTransition.noTransition,
                                       runImageTransitionIfCached: false) { (data) in
                                        if let _ = data.result.value {
                                            self.dealImageView?.contentMode = UIViewContentMode.scaleAspectFill
                                        }
        }
    }
    
}
