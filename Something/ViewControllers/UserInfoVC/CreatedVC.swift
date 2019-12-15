//
//  CreatedVC.swift
//  Something
//
//  Created by Maninder Singh on 11/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class CreatedVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var createdTableView: UITableView!
    
    //MARK:- Variables
    var userId = String()
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CreatePinVM.shared.getCreatedPins(userid: userId) { (value) in
            self.createdTableView.reloadData()
        }
        
    }
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods

}


//MARK:- Firebase Methods
extension CreatedVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CreatePinVM.shared.userPins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedCell") as! CreatedCell
        cell.selectionStyle = .none
        cell.titleLabel.text = CreatePinVM.shared.userPins[indexPath.row].pin.title
        cell.pinTypeLabel.text = CreatePinVM.shared.userPins[indexPath.row].pin.type
        cell.ratingStar.value = CGFloat(CreatePinVM.shared.userPins[indexPath.row].pin.rating)
        cell.ratingStar.isEnabled = false
        cell.checkInCount.text = "\(CreatePinVM.shared.userPins[indexPath.row].pin.visitedCount)" + " " + "check-ins"
        return cell
    }
}
