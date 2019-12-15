//
//  BioVC.swift
//  Something
//
//  Created by Maninder Singh on 11/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class BioVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var loactionLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    
    //MARK:- Variables
    var userId = String()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        UserVM.shared.getUserProfileDetail(userid: userId) { (value) in
            self.loactionLabel.text = UserVM.shared.userAddress.location
            self.webLabel.text = UserVM.shared.userAddress.webAddress
        }
    }
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods


}
