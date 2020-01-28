//
//  ChatVC.swift
//  Something
//
//  Created by Maninder Singh on 11/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class ChatVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var chatMessgaeTFView: UIView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var massageTF: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var navigationImageView: MSBImageView!
    
    //MARK:- Variables
    var roomId = String()
    var userImage = String()
    var userNameForNavigation = String()
    var otherUserId = String()
    var otherUserToken: String?
    var otherUserDetail : UserDetail!
    let refreshControl = UIRefreshControl()
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewHeight.constant = UIScreen.main.bounds.height - 64
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //Set RefreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            chatTableView.refreshControl = refreshControl
        } else {
            chatTableView.backgroundView = refreshControl
        }
        if let urlImaeg = URL(string: userImage){
            navigationImageView.sd_setImage(with: urlImaeg, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        userName.text = userNameForNavigation
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UserVM.shared.checkIsBlockedByMe(otherUser: otherUserDetail, completion: { isBlocked in
            if isBlocked{
                self.chatMessgaeTFView.isHidden = true
                self.showAlert(message: "You are not authorized to access this user")
            }else{
                self.chatMessgaeTFView.isHidden = false
            }
        })
        
        ChatVM.shared.lastMessageKey = ""
        ChatVM.shared.getChatMessages1(roomId: roomId, completion: { value in
            self.chatTableView.reloadData()
            if ChatVM.shared.chatMessages.count > 0 {
                self.chatTableView.scrollToRow(at: IndexPath(item:ChatVM.shared.chatMessages.count-1, section: 0), at: .bottom, animated: false)
            }
        })
    }
    //MARK:- IBActions
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButton(_ sender: Any) {
        if !massageTF.isEmpty{
            sendMessage()
        }
    }
    //MARK:- Custom Methods
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            self.chatTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
//            self.chatTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            self.chatTableView.contentInset = UIEdgeInsets.zero
//            self.chatTableView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        ChatVM.shared.getChatMessages1(roomId: roomId, completion: { value in
            self.chatTableView.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
}

extension ChatVC {
    
    func sendMessage(){
        print("sdsdsdfsdf")
        print(otherUserToken!)
        ChatVM.shared.sendLastMessage(roomId: roomId, message: massageTF.text!, senderId: DataManager.userId!, receiverId: otherUserId)
        
        let sender = PushNotificationSender()
        sender.sendPushNotification(to: "cVAq8suHDRU:APA91bFfzdkH1K37b7PVHnK6RZHsrzF2D9gt_9-kXSTWx51r03c3ZtuueQ-6zTMX7CAUk4qJnq0036bku5FFaz7HC0SuhW3TABRTZvjOeMjFBRXKUyOhCNzQw62cn_2BYuIXue1q8ngg", title: "Notification title", body: "Notification body")

        massageTF.text = ""
        print("dddddddd")
    }
}

//MARK;- TableView Methods
extension ChatVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatVM.shared.chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let otherCell = tableView.dequeueReusableCell(withIdentifier: "OtherChatCell") as! OtherChatCell
        let myCell = tableView.dequeueReusableCell(withIdentifier: "MyChatCell") as! MyChatCell
        otherCell.selectionStyle = .none
        myCell.selectionStyle = .none
        let chatmessage = ChatVM.shared.chatMessages[indexPath.row]
        if chatmessage.senderId == DataManager.userId!{
            myCell.messageLabel.text = chatmessage.message
            let time = self.timeAgoSinceDate(chatmessage.date)
            myCell.dateLabel.text = time
            return myCell
        }else{
            otherCell.messageLabel.text = chatmessage.message
            let time = self.timeAgoSinceDate(chatmessage.date)
            otherCell.dateLabel.text = time
            return otherCell
        }        
    }
}
