//
//  ChatVM.swift
//  Something
//
//  Created by Maninder Singh on 10/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import Foundation
import FirebaseDatabase


struct ChatList {
    var lastMsg : LastMsg?
    var user1 : UserDetail!
    var user2 : UserDetail!
    var roomId : String!
}

struct LastMsg {
    var date : Int!
    var message : String!
    var senderId : String!
}
class ChatVM{
    
    private init(){}
    static let shared = ChatVM()
    let ref : DatabaseReference = Database.database().reference()
    
    var chatList = [ChatList]()
    var chatMessages = [LastMsg]()
    
    //local Variable
    var lastMessageKey = ""
    
    func createChatRoom(user1 : UserDetail, user2 : UserDetail  ) -> (String,UserDetail,UserDetail){
        var firstUid : UserDetail!
        var secondUid : UserDetail!
        if user1.uid.compare(user2.uid).rawValue < 0{
            firstUid = user1
            secondUid = user2
        }else{
            firstUid = user2
            secondUid = user1
        }
        let roomId = firstUid.uid + secondUid.uid
        
        let updateUser1 = [FireBaseConstant.kEmail: firstUid.email,
                          FireBaseConstant.kName: firstUid.name,
                          FireBaseConstant.kNameForSearch: firstUid.name.uppercased(),
                          FireBaseConstant.kPhotoUrl:firstUid.photoUrl,
                          FireBaseConstant.kUid: firstUid.uid,
                          FireBaseConstant.kToken: firstUid.fcmToken,]
        let updateUser2 = [FireBaseConstant.kEmail: secondUid.email,
                           FireBaseConstant.kName: secondUid.name,
                           FireBaseConstant.kNameForSearch: secondUid.name.uppercased(),
                           FireBaseConstant.kPhotoUrl:secondUid.photoUrl,
                           FireBaseConstant.kUid: secondUid.uid,
                           FireBaseConstant.kToken: secondUid.fcmToken]
        
        ref.child(Chats).child(roomId).child(FireBaseConstant.kUser1).setValue(updateUser1)
        ref.child(Chats).child(roomId).child(FireBaseConstant.kUser2).setValue(updateUser2)
        return (roomId,user1,user2)
        
    }
    
    func sendLastMessage (roomId :String, message : String, senderId : String, receiverId : String){
        let lastMessage = [FireBaseConstant.kDate: [".sv": "timestamp"],
                           FireBaseConstant.kMessage: message,
                           FireBaseConstant.kUserId: senderId] as [String : Any]
        ref.child(Chats).child(roomId).child(FireBaseConstant.klastMsg).setValue(lastMessage)
        ref.child(ChatMessages).child(roomId).childByAutoId().updateChildValues(lastMessage)
        let updateNotification = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                  FireBaseConstant.kType : 4,
                                  FireBaseConstant.kTitle : DataManager.name ?? DataManager.email!,
                                  FireBaseConstant.kUser : MyUserDetail] as [String : Any]
        self.ref.child(UserNotifications).child(DataManager.userId!).childByAutoId().setValue(updateNotification)
        self.ref.child(UserChats).child(DataManager.userId!).setValue([roomId: true])
        self.ref.child(UserChats).child(receiverId).setValue([roomId: true])
        
    }
    
    
    func GetChatList(completion: @escaping (Bool) -> Void){
        ref.child(Chats).observeSingleEvent(of: .value) { (snapshot) in
            let children = snapshot.children.allObjects
            self.chatList.removeAll()
            for child in children{
                if let childSnapShot = child as? DataSnapshot{
                    let roomId = childSnapShot.key
                    if roomId.contains(DataManager.userId!){
                        var lastMessage = LastMsg()
                        if let childValues = childSnapShot.value as? NSDictionary{
                            
                            var user1 : UserDetail?
                            if let user1Dict = childValues[FireBaseConstant.kUser1] as? NSDictionary{
                                let email = user1Dict[FireBaseConstant.kEmail] as? String ?? ""
                                let name1 = user1Dict[FireBaseConstant.kName] as? String ?? ""
                                let photoUrl = user1Dict[FireBaseConstant.kPhotoUrl] as? String ?? ""
                                let uid = user1Dict[FireBaseConstant.kUid] as? String ?? ""
                                var fcmToken = String()
                         
                                
                                self.ref.child(UserFcmIds).observeSingleEvent(of: .value, with: { (snapshot) in
                                  // Get user value
                                    let value  = snapshot.value as? NSDictionary
                                    fcmToken = value?[uid] as? String ?? ""
                                    print("____________here____________")
                                    print(uid)
                                  }) { (error) in
                                    print(error.localizedDescription)
                                }
                                
                                user1 = UserDetail(name: name1, email: email, photoUrl: photoUrl, uid: uid, fcmToken: fcmToken)
                                
                            }
                            var user2 : UserDetail?
                            if let user2Dict = childValues[FireBaseConstant.kUser2] as? NSDictionary{
                                let email = user2Dict[FireBaseConstant.kEmail] as? String ?? ""
                                let name1 = user2Dict[FireBaseConstant.kName] as? String ?? ""
                                let photoUrl = user2Dict[FireBaseConstant.kPhotoUrl] as? String ?? ""
                                let uid = user2Dict[FireBaseConstant.kUid] as? String ?? ""
                                var fcmToken = String()
                                self.ref.child(UserFcmIds).observeSingleEvent(of: .value, with: { (snapshot) in
                                                                  // Get user value
                                    let value  = snapshot.value as? NSDictionary
                                    fcmToken = value?[uid] as? String ?? ""
                                    print("____________here____________")
                                    print(uid)
                                   
                                                                  // ...
                                                                  }) { (error) in
                                                                    print(error.localizedDescription)
                                                                }
                                user2 = UserDetail(name: name1, email: email, photoUrl: photoUrl, uid: uid, fcmToken: fcmToken)
                            }
                            if let lastMsgDict = childValues[FireBaseConstant.klastMsg] as? NSDictionary{
                                let date = lastMsgDict[FireBaseConstant.kDate] as? Int ?? 0
                                let message = lastMsgDict[FireBaseConstant.kMessage] as? String ?? ""
                                let senderId = lastMsgDict[FireBaseConstant.kUserId] as! String
                                lastMessage = LastMsg(date: date, message: message, senderId: senderId)
                                self.chatList.append(ChatList(lastMsg: lastMessage, user1: user1!, user2: user2!,roomId: roomId))
                            }
                            
                        }
                    }
                }
            }
            completion(true)
        }
    }
    
    
    
    func getChatMessages1(roomId: String,completion: @escaping (Bool) -> Void){
        let messagesRef = ref.child(ChatMessages).child(roomId)
        if lastMessageKey == ""{
            messagesRef.queryOrderedByKey().queryLimited(toLast: 10).observe(.value) { (snapshot) in
                if snapshot.exists(){
                    let children = snapshot.children
                    self.chatMessages.removeAll()
                    for (index,child) in children.enumerated(){
                        if let childsnapShot = child as? DataSnapshot{
                            if index == 0{
                                self.lastMessageKey = childsnapShot.key
                            }
                            if let lastMsgDict = childsnapShot.value as? NSDictionary{
                                let date = lastMsgDict[FireBaseConstant.kDate] as? Int ?? 0
                                let message = lastMsgDict[FireBaseConstant.kMessage] as? String ?? ""
                                let senderId = lastMsgDict[FireBaseConstant.kUserId] as! String
                                self.chatMessages.append(LastMsg(date: date, message: message, senderId: senderId))
                            }
                        }
                    }
                    
                    completion(true)
                }
            }
        }else{
            messagesRef.queryOrderedByKey().queryLimited(toLast: 11).queryEnding(atValue: lastMessageKey).observe(.value, with: { (snapshot) in
                print(snapshot)
                if snapshot.exists(){
                    var count = 0
                    let children = snapshot.children
                    var newPage = [LastMsg]()
                    for (index,child) in children.enumerated(){
                        if (count == snapshot.childrenCount - 1) {
                            break
                        }
                        if let childsnapShot = child as? DataSnapshot{
                            count = count + 1
                            if index == 0{
                                self.lastMessageKey = childsnapShot.key
                            }
                            if let lastMsgDict = childsnapShot.value as? NSDictionary{
                                let date = lastMsgDict[FireBaseConstant.kDate] as? Int ?? 0
                                let message = lastMsgDict[FireBaseConstant.kMessage] as? String ?? ""
                                let senderId = lastMsgDict[FireBaseConstant.kUserId] as! String
                                newPage.append(LastMsg(date: date, message: message, senderId: senderId))
                            }
                        }
                    }
                    self.chatMessages.insert(contentsOf: newPage, at: 0)
                    print(self.chatMessages)
                    completion(true)
                }
            })
        }
        
        

    }
    
    func getChatsMessages(roomId: String,completion: @escaping (Bool) -> Void){
        ref.child(ChatMessages).child(roomId).observe(.value) { (snapShot) in
            if snapShot.exists(){
                let children = snapShot.children
                self.chatMessages.removeAll()
                for child in children{
                    if let childsnapShot = child as? DataSnapshot{
                        if let lastMsgDict = childsnapShot.value as? NSDictionary{
                            let date = lastMsgDict[FireBaseConstant.kDate] as? Int ?? 0
                            let message = lastMsgDict[FireBaseConstant.kMessage] as? String ?? ""
                            let senderId = lastMsgDict[FireBaseConstant.kUserId] as! String
                            self.chatMessages.append(LastMsg(date: date, message: message, senderId: senderId))
                        }
                    }
                }
                completion(true)
            }
        }
    }
    
    
    
    
    

}
