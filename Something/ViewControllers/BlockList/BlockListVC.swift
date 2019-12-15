//
//  BlockListVC.swift
//  Something
//
//  Created by Maninder Singh on 19/08/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class BlockListVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var noUserLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Variables
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserVM.shared.blockedList.removeAll()
        UserVM.shared.getBlockList(completion: { success in
            if UserVM.shared.blockedList.count == 0{
                self.noUserLabel.isHidden = false
            }else{
                self.noUserLabel.isHidden = true
            }
            self.tableView.reloadData()
        })
    }
    
    //MARK:- IBActions
    @IBAction func menuButtonAction(_ sender: Any) {
        panel?.openLeft(animated: true)
    }
    
    
    //MARK:- Custom Methods

 

}


//MARK: -TbaleView Methods
extension BlockListVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserVM.shared.blockedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowCell
        cell.selectionStyle = .none
        cell.userNameLabel.text = UserVM.shared.blockedList[indexPath.row].name
        let imageString = UserVM.shared.blockedList[indexPath.row].photoUrl
        if let Url = URL(string: imageString){
            cell.userImageView.sd_setImage(with: Url, placeholderImage: #imageLiteral(resourceName: "user"), options:[], completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            UserVM.shared.removeFromBlockList(blockedUser: UserVM.shared.blockedList[indexPath.row])
            UserVM.shared.blockedList.removeAll()
            UserVM.shared.getBlockList(completion: { success in
                if UserVM.shared.blockedList.count == 0{
                    self.noUserLabel.isHidden = false
                }else{
                    self.noUserLabel.isHidden = true
                }
                self.tableView.reloadData()
            })
        }
    }
    
    
}
