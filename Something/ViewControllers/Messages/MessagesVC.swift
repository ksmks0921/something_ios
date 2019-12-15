//
//  MessagesVC.swift
//  Something
//
//  Created by Maninder Singh on 02/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import FAPanels

class MessagesVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var listTableView: UITableView!
    
    //MARK:- Variables
    var chatList = [ChatList]()
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Indicator.sharedInstance.showIndicator()
        ChatVM.shared.GetChatList(completion: { value in
            Indicator.sharedInstance.hideIndicator()
            self.chatList = ChatVM.shared.chatList
            self.listTableView.reloadData()
        })
    }
    
    //MARK:- IBActions
    @IBAction func menuButtonAction(_ sender: Any) {
        panel?.openLeft(animated: true)
    }
    
    @IBAction func newChatButton(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SearchUserVC") as! SearchUserVC
        VC.isFromMessageVC = true
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    //MARK:- Custom Methods

}

//MARK:- TableView Methods
extension MessagesVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        cell.selectionStyle = .none
        if let lstMsg = chatList[indexPath.row].lastMsg{
            cell.dateLabel.text = self.timeAgoSinceDate(lstMsg.date)
            
            cell.lastMessageLabel.text = lstMsg.message
        }
        let userDetail : UserDetail?
        if chatList[indexPath.row].user1.uid == DataManager.userId!{
            userDetail = chatList[indexPath.row].user2
        }else{
            userDetail = chatList[indexPath.row].user1
        }
        cell.nameLabel.text = userDetail?.name ?? ""
        if let StringUrl = userDetail?.photoUrl{
            if let imageUrl = URL(string: StringUrl){
                cell.userImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        let userDetail : UserDetail?
        if chatList[indexPath.row].user1.uid == DataManager.userId!{
            userDetail = chatList[indexPath.row].user2
        }else{
            userDetail = chatList[indexPath.row].user1
        }
        VC.userNameForNavigation = userDetail?.name ?? ""
        VC.otherUserId = userDetail?.uid ?? ""
        VC.roomId = chatList[indexPath.row].roomId
        VC.userImage =  userDetail?.photoUrl ?? ""
        VC.otherUserDetail = userDetail
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
}
