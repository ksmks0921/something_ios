//
//  SearchUserVC.swift
//  Something
//
//  Created by Maninder Singh on 10/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class SearchUserVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var usersTableView: UITableView!
    
    //MARK:- Variables
    var searchedUsers = [UserDetail]()
    var isFromMessageVC = true
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTF.delegate = self
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Custom Methods


}

//MARK: -TbaleView Methods
extension SearchUserVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowCell
        cell.selectionStyle = .none
        cell.userNameLabel.text = searchedUsers[indexPath.row].name
        let imageString = searchedUsers[indexPath.row].photoUrl
        if let Url = URL(string: imageString){
            cell.userImageView.sd_setImage(with: Url, placeholderImage: #imageLiteral(resourceName: "user"), options:[], completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserVM.shared.checkIsBlockedByMe(otherUser: searchedUsers[indexPath.row]) { (isBlocked) in
            if isBlocked{
                self.showAlert(message: "You are not authorized to access this user")
            }else{
                if self.isFromMessageVC{
                    let myid = UserDetail(name: DataManager.name!, email: DataManager.email!, photoUrl: DataManager.UserImageURL ?? "", uid: DataManager.userId!)
                    let otherUser = self.searchedUsers[indexPath.row]
                    let roomId = ChatVM.shared.createChatRoom(user1: otherUser, user2: myid)
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                    let tupleData = roomId
                    let userDetail : UserDetail?
                    if tupleData.1.uid == DataManager.userId!{
                        userDetail = tupleData.2
                    }else{
                        userDetail = tupleData.1
                    }
                    VC.roomId = tupleData.0
                    VC.userNameForNavigation = userDetail?.name ?? ""
                    VC.otherUserId = userDetail?.uid ?? ""
                    VC.userImage = userDetail?.photoUrl ?? ""
                    VC.otherUserDetail = userDetail
                    self.navigationController?.pushViewController(VC, animated: true)
                }else{
                    let userDetail = self.searchedUsers[indexPath.row]
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as! UserInfoVC
                    VC.userDetail = userDetail
                    self.navigationController?.pushViewController(VC, animated: true)
                    
                }
            }
        }
        
        
    }
    
    
}

//MAKR:- Search Friends
extension SearchUserVC{
    
    func getUsers(){
        UserVM.shared.searchUsers(name: searchTF.text!.uppercased(), completion: {value in
            self.searchedUsers = UserVM.shared.searchedUses
            self.usersTableView.reloadData()
        })
    }
    
}

extension SearchUserVC: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        getUsers()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEmpty{
            self.showAlert(message: "Please enter name for search.")
        }else{
            getUsers()
        }
        return true
    }
    
}
