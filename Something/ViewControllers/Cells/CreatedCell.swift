//
//  CreatedCell.swift
//  Something
//
//  Created by Maninder Singh on 13/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import HCSStarRatingView

class CreatedCell: UITableViewCell {

    @IBOutlet weak var checkInCount: UILabel!
    @IBOutlet weak var pinTypeLabel: UILabel!
    @IBOutlet weak var ratingCount: UILabel!
    @IBOutlet weak var ratingStar: HCSStarRatingView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
