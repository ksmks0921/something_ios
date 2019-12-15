//
//  ChatListCell.swift
//  Something
//
//  Created by Maninder Singh on 11/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {

    @IBOutlet weak var userImageView: MSBImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
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
