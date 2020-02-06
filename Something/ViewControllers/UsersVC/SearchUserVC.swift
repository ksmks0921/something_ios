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
    @IBOutlet weak var custom_title: UILabel!
    
    //MARK:- Variables
    var searchedUsers = [UserDetail]()
    var searchedPins = [PinsSnapShot]()
    var isFrom : String?
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTF.delegate = self
        
        if isFrom == "home" {
            let nib = UINib.init(nibName: "CreatedCell", bundle: nil)
            self.usersTableView.register(nib, forCellReuseIdentifier: "CreatedCell")
            custom_title.text = "Pins"
            searchTF.placeholder = "Search Pins"
  
        }
       
        print("isFrom is " + isFrom!)
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
        if self.isFrom == "home" {
             return searchedPins.count
        }
        else {
             return searchedUsers.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isFrom == "home" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedCell") as! CreatedCell
            cell.selectionStyle = .none
            cell.titleLabel.text = searchedPins[indexPath.row].title
            cell.pinTypeLabel.text = searchedPins[indexPath.row].type
            cell.ratingStar.value = CGFloat(searchedPins[indexPath.row].rating)
            cell.ratingStar.isEnabled = false
//            cell.checkInCount.text = "\(CreatePinVM.shared.userPins[indexPath.row].pin.visitedCount)" + " " + "check-ins"
            
            return cell
        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowCell
            cell.selectionStyle = .none
            cell.userNameLabel.text = searchedUsers[indexPath.row].name
            let imageString = searchedUsers[indexPath.row].photoUrl
            if let Url = URL(string: imageString){
                cell.userImageView.sd_setImage(with: Url, placeholderImage: #imageLiteral(resourceName: "user"), options:[], completed: nil)
            }
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFrom == "home" {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            VC.searchedArray = searchedPins
            VC.isFromSearchPinVC = true
            VC.searched_pin_index = indexPath.row
            self.navigationController?.pushViewController(VC, animated: true)
        }
        else {
            
            UserVM.shared.checkIsBlockedByMe(otherUser: searchedUsers[indexPath.row]) { (isBlocked) in
                       if isBlocked{
                           self.showAlert(message: "You are not authorized to access this user")
                       } else{
                           if self.isFrom == "message"{
                               
                               
                               let myid = UserDetail(name: DataManager.name!, email: DataManager.email!, photoUrl: DataManager.UserImageURL ?? "", uid: DataManager.userId!, fcmToken: DataManager.deviceToken!)
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
                               VC.otherUserToken = userDetail?.fcmToken ?? "otherUserToken"
                               
                               VC.userImage = userDetail?.photoUrl ?? ""
                               VC.otherUserDetail = userDetail
                               self.navigationController?.pushViewController(VC, animated: true)
                           }
                           
                           else {
                               let userDetail = self.searchedUsers[indexPath.row]
                               let VC = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as! UserInfoVC
                               VC.userDetail = userDetail
                               
                               self.navigationController?.pushViewController(VC, animated: true)
                               
                           }
                       }
                   }
                   
                   
               }
        }
        
    
    
}

//MAKR:- Search Friends
extension SearchUserVC{
    
    func getUsers(){
        print("________searching users____________")
        UserVM.shared.searchUsers(name: searchTF.text!.uppercased(), completion: {value in
            self.searchedUsers = UserVM.shared.searchedUses
            self.usersTableView.reloadData()
        })
    }
    
    func getPinsForSearch(){
        print("________searching pins____________")
        CreatePinVM.shared.getSearchedPins(key: searchTF.text!, completion: {value in
            self.searchedPins = CreatePinVM.shared.searchedpinsData
            self.usersTableView.reloadData()
        })
    }
    
}

extension SearchUserVC: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.isFrom == "home" {
            getPinsForSearch()
           
        }
        else {
            getUsers()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEmpty{
            self.showAlert(message: "Please enter name for search.")
        }else{

            if self.isFrom == "home" {
                getPinsForSearch()
            }
            else {
                getUsers()
            }
            
        }
        return true
    }
    
}
