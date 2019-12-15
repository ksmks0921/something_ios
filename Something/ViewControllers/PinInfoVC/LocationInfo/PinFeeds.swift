//
//  PinFeeds.swift
//  Something
//
//  Created by Maninder Singh on 15/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class PinFeeds: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var feedsTableView: UITableView!
    
    //MARK:- Variables
    var pinDetail : PinsSnapShot!
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        UpdatePinVM.shared.getPinsFeeds(pidId: pinDetail.key) { (success) in
            self.feedsTableView.reloadData()
        }
        
    }
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods

}

//MARK:- TableView methods
extension PinFeeds : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UpdatePinVM.shared.pinsFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsCell") as! FeedsCell
        cell.selectionStyle = .none
        let feed =  UpdatePinVM.shared.pinsFeed[indexPath.row]
        if feed.type == 0{
            cell.activityTitle.text = "Created by " + feed.user.name
            cell.activityImage.image = #imageLiteral(resourceName: "maps-and-flags")
        }
        if feed.type == 1{
            cell.activityTitle.text = "Commented by " + feed.user.name
            cell.activityImage.image = #imageLiteral(resourceName: "black-bubble-speech")
        }
        if feed.type == 2{
            cell.activityTitle.text = "Checked in by " + feed.user.name
            cell.activityImage.image = #imageLiteral(resourceName: "location_right_icon-1")
        }
        if feed.type == 3{
            cell.activityTitle.text = "Rated by " + feed.user.name
             cell.activityImage.image = #imageLiteral(resourceName: "star-1")
        }
        if feed.type == 6{
            cell.activityTitle.text = "Updated pin info by " + feed.user.name
            cell.activityImage.image = #imageLiteral(resourceName: "location_right_icon-1")
        }
        cell.avitivtyDate.text = self.timeAgoSinceDate(feed.date)
        
        return cell
    }
}
