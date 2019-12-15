//
//  HomePageCell.swift
//  Something
//
//  Created by Maninder Singh on 02/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import HCSStarRatingView

class HomePageCell: UICollectionViewCell {
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var markerType: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var checkInCountLabel: UILabel!
    @IBOutlet weak var markerButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var wishListImageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var checkInView: UIView!
    @IBOutlet weak var wishListView: UIView!
    @IBOutlet weak var checkInImageView: UIImageView!
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editButton: UIButton!
    override func prepareForReuse() {
        locationImage.image = nil
        locationImage.sd_cancelCurrentAnimationImagesLoad()
    }
}
