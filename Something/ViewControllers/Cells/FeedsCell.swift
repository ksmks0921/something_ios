//
//  FeedsCell.swift
//  Something
//
//  Created by Maninder Singh on 18/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class FeedsCell: UITableViewCell {

    @IBOutlet weak var activityImage: MSBImageView!
    @IBOutlet weak var avitivtyDate: UILabel!
    @IBOutlet weak var activityTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
