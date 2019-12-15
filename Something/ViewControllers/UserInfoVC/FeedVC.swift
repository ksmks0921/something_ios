//
//  FeedVC.swift
//  Something
//
//  Created by Maninder Singh on 11/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class FeedVC: BaseVC {

    //MARK:- IBOutlets
    

    @IBOutlet weak var feedsTableview: UITableView!
    
    //MARK:- Variables
     var userId = String()
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CreatePinVM.shared.getUserActivity(userId: userId) { (success) in
            self.feedsTableview.reloadData()
        }
    }
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods

}

//MARK:- TableView methods
extension FeedVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CreatePinVM.shared.userFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsCell") as! FeedsCell
        cell.selectionStyle = .none
        let feed =  CreatePinVM.shared.userFeeds[indexPath.row]
        if feed.type == 0{
            cell.activityTitle.text = "Created " + feed.pin.type + " " + feed.pin.title
            cell.activityImage.image = #imageLiteral(resourceName: "maps-and-flags")
        }
        if feed.type == 1{
            cell.activityTitle.text = "Commented on " + feed.pin.type + " " + feed.pin.title
            cell.activityImage.image = #imageLiteral(resourceName: "black-bubble-speech")
        }
        if feed.type == 2{
            cell.activityTitle.text = "Checked in " + feed.pin.type + " " + feed.pin.title
            cell.activityImage.image = #imageLiteral(resourceName: "location_right_icon-1")
        }
        if feed.type == 3{
            cell.activityTitle.text = "Rated to " + feed.pin.type + " " + feed.pin.title
            cell.activityImage.image = #imageLiteral(resourceName: "star-1")
        }
        cell.avitivtyDate.text = self.timeAgoSinceDate(feed.date)
        
        return cell
    }
}
