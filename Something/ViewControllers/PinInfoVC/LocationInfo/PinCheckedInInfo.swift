//
//  PinCheckedInInfo.swift
//  Something
//
//  Created by Maninder Singh on 15/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class PinCheckedInInfo: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var checkedInTableView: UITableView!
    @IBOutlet weak var noCheckInLabel: UILabel!
    
    //MARK:- Variables
    var pinDetail : PinsSnapShot!
    var isMissedPin = false
    var isVisitedPin = false
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CreatePinVM.shared.getPinCheckedInUsers(pinId: pinDetail.key) { (success) in
            if CreatePinVM.shared.pinVisitedUsers.count == 0{
                self.noCheckInLabel.isHidden = false
                self.checkedInTableView.isHidden = true
            }else{
                self.noCheckInLabel.isHidden = true
                self.checkedInTableView.isHidden = false
            }
            self.checkedInTableView.reloadData()
        }
    }
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods


}


extension PinCheckedInInfo : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CreatePinVM.shared.pinVisitedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "PinCheckedInCell") as! PinCheckedInCell
        let pindUserDetail = CreatePinVM.shared.pinVisitedUsers[indexPath.row]
        let imageString = pindUserDetail.user.photoUrl
        if let imageURL = URL(string: imageString){
            cell.userImage.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        
        cell.userName.text = pindUserDetail.user.name
        let dateInSeconds = Double(pindUserDetail.visitedDate / 1000)
        let date = Date(timeIntervalSince1970: dateInSeconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        cell.userDate.text = dateFormatter.string(from: date)
        return cell
    }
}
