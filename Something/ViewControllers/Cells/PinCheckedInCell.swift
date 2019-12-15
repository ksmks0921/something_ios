//
//  PinCheckedInCell.swift
//  Something
//
//  Created by Maninder Singh on 16/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class PinCheckedInCell: UITableViewCell {

    @IBOutlet weak var userDate: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: MSBImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
