//
//  NotificationVC.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class NotificationVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var notiFicationTable: UITableView!
    
    //MARK:- Variables
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        UpdatePinVM.shared.notifications.removeAll()
        UpdatePinVM.shared.getnotifications { (success) in
            self.notiFicationTable.reloadData()
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Custom Methods


}


extension NotificationVC : UITableViewDataSource,UITabBarDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UpdatePinVM.shared.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        cell.selectionStyle = .none
        let noti = UpdatePinVM.shared.notifications[indexPath.row]
        if noti.type == 0{
            cell.notificatinDate.text = self.timeAgoSinceDate(noti.date)
            cell.notificationTitle.text = noti.pin.title
            cell.notificationDescription.text = noti.pin.title + "is not so far away"
            cell.imageNotification.image = #imageLiteral(resourceName: "maps-and-flags")
        }
        if noti.type == 1{
            cell.notificatinDate.text = self.timeAgoSinceDate(noti.date)
            cell.notificationTitle.text = noti.pin.title
            cell.notificationDescription.text = noti.pin.title + "is commented by \(noti.user?.name ?? "")"
            cell.imageNotification.image = #imageLiteral(resourceName: "black-bubble-speech")
        }
        if noti.type == 2{
            cell.notificatinDate.text = self.timeAgoSinceDate(noti.date)
            cell.notificationTitle.text = noti.pin.title
            cell.notificationDescription.text = noti.pin.title + "is checked-in by \(noti.user?.name ?? "")"
            cell.imageNotification.image = #imageLiteral(resourceName: "location_right_icon-1")
        }
        if noti.type == 3{
            cell.notificatinDate.text = self.timeAgoSinceDate(noti.date)
            cell.notificationTitle.text = noti.pin.title
            cell.notificationDescription.text = noti.pin.title + "is rated by \(noti.user?.name ?? "")"
            cell.imageNotification.image = #imageLiteral(resourceName: "star-1")
        }
        if noti.type == 4{
            cell.notificatinDate.text = self.timeAgoSinceDate(noti.date)
            cell.notificationTitle.text = "New message"
            cell.notificationDescription.text = (noti.user?.name ?? "") + "is send you a message"
            cell.imageNotification.image = #imageLiteral(resourceName: "black-bubble-speech")
        }
        if noti.type == 6{
            cell.notificatinDate.text = self.timeAgoSinceDate(noti.date)
            cell.notificationTitle.text = noti.pin.title
            cell.notificationDescription.text = noti.pin.title + "has update pin info"
            cell.imageNotification.image = #imageLiteral(resourceName: "location_right_icon-1")
        }
        if noti.type == 7{
            cell.notificatinDate.text = self.timeAgoSinceDate(noti.date)
            cell.notificationTitle.text = noti.pin.title
            cell.notificationDescription.text = noti.pin.title + "has been deleted."
            cell.imageNotification.image = #imageLiteral(resourceName: "location_right_icon-1")
        }
   

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let itemkey = UpdatePinVM.shared.notifications[indexPath.row].key
            UpdatePinVM.shared.deleteNotification(key: itemkey!)
            UpdatePinVM.shared.notifications.remove(at: indexPath.row)
            notiFicationTable.deleteRows(at: [indexPath], with: .left)
        }
    }

}
