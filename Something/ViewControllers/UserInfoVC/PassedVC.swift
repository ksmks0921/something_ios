//
//  PassedVC.swift
//  Something
//
//  Created by Maninder Singh on 14/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class PassedVC: BaseVC {
    //MARK:- IBOutlets
    
    @IBOutlet weak var missdedPinTableView: UITableView!
    
    //MARK:- Variables
    var userId = String()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CreatePinVM.shared.getMissedPins(userid: userId) { (value) in
            self.missdedPinTableView.reloadData()
        }
    }
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods


}

//MARK:- Firebase Methods
extension PassedVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CreatePinVM.shared.missedPins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedCell") as! CreatedCell
        cell.selectionStyle = .none
        cell.titleLabel.text = CreatePinVM.shared.missedPins[indexPath.row].pin.title
        cell.pinTypeLabel.text = CreatePinVM.shared.missedPins[indexPath.row].pin.type
        cell.ratingStar.value = CGFloat(CreatePinVM.shared.missedPins[indexPath.row].pin.rating)
        cell.ratingStar.isEnabled = false
        cell.checkInCount.text = "\(CreatePinVM.shared.missedPins[indexPath.row].pin.visitedCount)" + " " + "check-ins"
        return cell
    }
}
