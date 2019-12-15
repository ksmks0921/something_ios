//
//  CheckedInVC.swift
//  Something
//
//  Created by Maninder Singh on 11/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class CheckedInVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var checkedInTableView: UITableView!
    
    //MARK:- Variables
     var userId = String()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CreatePinVM.shared.getVisitedPins(userid: userId, completion: { (value) in
            self.checkedInTableView.reloadData()
        })
    }
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods
}


extension CheckedInVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CreatePinVM.shared.visitedPins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedCell") as! CreatedCell
        cell.selectionStyle = .none
        cell.titleLabel.text = CreatePinVM.shared.visitedPins[indexPath.row].pin.title
        cell.pinTypeLabel.text = CreatePinVM.shared.visitedPins[indexPath.row].pin.type
        cell.ratingStar.value = CGFloat(CreatePinVM.shared.visitedPins[indexPath.row].pin.rating)
        cell.ratingStar.isEnabled = false
        cell.checkInCount.text = "\(CreatePinVM.shared.visitedPins[indexPath.row].pin.visitedCount)" + " " + "check-ins"
        return cell
        
    }
}
