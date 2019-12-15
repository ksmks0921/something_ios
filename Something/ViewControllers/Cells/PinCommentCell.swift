//
//  PinCommentCell.swift
//  Something
//
//  Created by Maninder Singh on 16/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class PinCommentCell: UITableViewCell {
    @IBOutlet weak var userImage: MSBImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
