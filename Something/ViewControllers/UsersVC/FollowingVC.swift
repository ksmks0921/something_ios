//
//  FollowingVC.swift
//  Something
//
//  Created by Maninder Singh on 02/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FollowingVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var followingTableView: UITableView!
    
    //MARK:- Variables
    var ref : DatabaseReference!
    var followingUser = [UserDetail]()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getFollowingUser()
    }
    
    //MARK:- IBActions
    

    //MARK:- Custom Methods

    func getFollowingUser(){
        self.followingUser.removeAll()
        ref.child(UserSubscriptions).child(DataManager.userId!).observe(.value) { (snapShot) in
            var key = ""
            if let value = snapShot.value as? NSDictionary{
                let allkey = value.allKeys
                if allkey.count > 0{
                    key = allkey[0] as! String
                }else{
                    return
                }
            }else{
                return
            }
            
            self.ref.child(UserNode).child(key).observeSingleEvent(of: .value) { (snapShot) in
                if snapShot.exists(){
                    let user = UserVM.shared.parasUserDetail(user: snapShot.value as! NSDictionary)
                    if self.followingUser.count == 0{
                        self.followingUser.insert(user, at: 0)
                        self.followingTableView.beginUpdates()
                        self.followingTableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                        self.followingTableView.endUpdates()
                    }else{
                        self.followingTableView.beginUpdates()
                        self.followingUser.append(user)
                        self.followingTableView.insertRows(at: [IndexPath(row: self.followingUser.count-1, section: 0)], with: .bottom)
                        self.followingTableView.endUpdates()
                    }
                    
                }else{
                    print("no user exits")
                }
            }
        }
    }
}


//MARK:- TableView Methods
extension FollowingVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowCell
        cell.selectionStyle = .none
        cell.userNameLabel.text = followingUser[indexPath.row].name
        let imageString = followingUser[indexPath.row].photoUrl
        if let Url = URL(string: imageString){
            cell.userImageView.sd_setImage(with: Url, placeholderImage: #imageLiteral(resourceName: "user"), options:[], completed: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserVM.shared.checkIsBlockedByMe(otherUser: followingUser[indexPath.row]) { (isblocked) in
            if isblocked{
                self.showAlert(message: "You are not authorized to access this user")
            }else{
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as! UserInfoVC
                VC.userDetail = self.followingUser[indexPath.row]
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
        
    }
    
}
