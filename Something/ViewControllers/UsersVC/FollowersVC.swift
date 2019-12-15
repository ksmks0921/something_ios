//
//  FollowersVC.swift
//  Something
//
//  Created by Maninder Singh on 02/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FollowersVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var followersTableView: UITableView!
    
    //MARK:- Variables
    var followerUser = [UserDetail]()
    var ref : DatabaseReference!
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getFollowerUser()
    }
    

    
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods
    func getFollowerUser(){
        self.followerUser.removeAll()
        ref.child(UserSubscribers).child(DataManager.userId!).observeSingleEvent(of: .value) { (snapShot) in
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
                    if self.followerUser.count == 0{
                        self.followerUser.insert(user, at: 0)
                        self.followersTableView.beginUpdates()
                        self.followersTableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                        self.followersTableView.endUpdates()
                    }else{
                        self.followersTableView.beginUpdates()
                        self.followerUser.append(user)
                        self.followersTableView.insertRows(at: [IndexPath(row: self.followerUser.count-1, section: 0)], with: .bottom)
                        self.followersTableView.endUpdates()
                    }
                    
                }else{
                    print("no user exits")
                }
            }
        }
    }
}

//MARK:- TableView Methods
extension FollowersVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followerUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowCell
        cell.selectionStyle = .none
        cell.userNameLabel.text = followerUser[indexPath.row].name
        let imageString = followerUser[indexPath.row].photoUrl
        if let Url = URL(string: imageString){
            cell.userImageView.sd_setImage(with: Url, placeholderImage: #imageLiteral(resourceName: "user"), options:[], completed: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserVM.shared.checkIsBlockedByMe(otherUser: followerUser[indexPath.row]) { (isblocked) in
            if isblocked{
                self.showAlert(message: "You are not authorized to access this user")
            }else{
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as! UserInfoVC
                VC.userDetail = self.followerUser[indexPath.row]
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
        
    }
    
    
}
