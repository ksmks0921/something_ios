//
//  NotificationCell.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var notificatinDate: UILabel!
    @IBOutlet weak var imageNotification: MSBImageView!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var notificationDescription: UILabel!
    @IBOutlet weak var viewForShadow: MSBView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewForShadow.layer.cornerRadius = 5
        viewForShadow.dropShadow(color: UIColor.lightGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
