//
//  FollowCell.swift
//  Something
//
//  Created by Maninder Singh on 02/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class FollowCell: UITableViewCell {

    @IBOutlet weak var userImageView: MSBImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        userImageView.image = #imageLiteral(resourceName: "user")
        sd_cancelCurrentImageLoad()
    }
}
