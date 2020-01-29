//
//  UserVM.swift
//  FriendsApp
//
//  Created by Maninder Singh on 21/10/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

typealias JSONDictionary = [String:Any]
typealias JSONArray = [JSONDictionary]
typealias APIServiceSuccessCallback = ((Any?) -> ())
typealias JSONArrayResponseCallback = ((JSONArray?) -> ())
typealias OwnArray = ((NSArray?) -> ())
typealias JSONDictionaryResponseCallback = ((JSONDictionary?) -> ())
typealias responseCallBack = ((Bool, String?, NSError?) -> ())


struct UserLocationAndWeb {
    var location : String!
    var webAddress: String!
}


class UserVM{
    
    private init(){}
    static let shared = UserVM()
    let ref : DatabaseReference = Database.database().reference()
    var searchedUses = [UserDetail]()
    var userAddress = UserLocationAndWeb()
    var blockedList = [UserDetail]()
    var email: String?
  
    //MARK: User Methods
    func login(email: String, password: String, response: @escaping responseCallBack){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            Indicator.sharedInstance.hideIndicator()
            if error == nil{
                DataManager.userId = user?.user.uid
                DataManager.email = user?.user.email
                self.ref.child(UserFcmIds).child(DataManager.userId!).removeValue()
                self.ref.child(UserFcmIds).child(DataManager.userId!).child(DataManager.deviceToken ?? "" ).setValue(true)
                response(true, "Login Successfully.", nil)
            }else{
               response(false, error?.localizedDescription, nil)
            }
        }
    }
    
    func singUp(email: String, password: String, name : String, response: @escaping responseCallBack){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil{
                DataManager.userId = user?.user.uid
                DataManager.email = user?.user.email
                DataManager.name = name
                let updateUser = [FireBaseConstant.kEmail: DataManager.email!,
                                  FireBaseConstant.kName: DataManager.name!,
                                  FireBaseConstant.kNameForSearch: DataManager.name!.uppercased(),
                                  FireBaseConstant.kPhotoUrl:"",
                                  FireBaseConstant.kUid: DataManager.userId!,
                                  FireBaseConstant.kToken: DataManager.deviceToken!,
                ]
                self.ref.child(UserNode).child(DataManager.userId!).setValue(updateUser)                
                self.ref.child(UserFcmIds).child(DataManager.userId!).child(DataManager.deviceToken!).setValue(true)
                response(true, "Registered Successfully.", nil)
            }else{
                response(false, error?.localizedDescription, nil)
            }
        }
    }
    
    func searchUsers(name : String, completion: @escaping (Bool) -> Void){
        searchedUses.removeAll()
        ref.child(UserNode).observeSingleEvent(of: .value) { (snapShot) in
            let children = snapShot.children.allObjects
            for child in children{
                if let childSnapshot = child as? DataSnapshot{
                    let childDict = childSnapshot.value as! NSDictionary
                    let nameForSearch = childDict[FireBaseConstant.kNameForSearch] as? String ?? ""
                    if nameForSearch.contains(name){
                        
                        let email = childDict[FireBaseConstant.kEmail] as? String ?? ""
                        let name1 = childDict[FireBaseConstant.kName] as? String ?? ""
                        let photoUrl = childDict[FireBaseConstant.kPhotoUrl] as? String ?? ""
                        let uid = childDict[FireBaseConstant.kUid] as? String ?? ""
                        let fcmToken = childDict[FireBaseConstant.kToken] as? String ?? ""
//                        var fcmToken = String()
//
//                        self.ref.child(UserFcmIds).child(uid).observe(.value) { (snap) in
//
//                                if let valuedict = snap.value as? NSDictionary{
//                                    let fcmIds = valuedict.allKeys
//                                    for key in fcmIds{
//                                        if key is String{
//
//                                            fcmToken = key as! String
//                                            print("________opoos")
//                                            print(fcmToken)
//
//
//                                        }
//                                    }
//                                }
//                        }
                        self.searchedUses.append(UserDetail(name: name1, email: email, photoUrl: photoUrl, uid: uid, fcmToken: fcmToken))
                        
                        
                        
                        
                    }
                }
            }
            completion(true)
        }
//        ref.child(UserNode).queryOrdered(byChild: FireBaseConstant.kNameForSearch)
//            .queryEqual(toValue: name.capitalized)
//            .observeSingleEvent(of: .value, with: { snapshot in
//                if snapshot.exists(){
//                    print(snapshot)
//                }
//            })

    }
    
    func editProfile(name : String, location : String, webaddress: String){
        let dict = [FireBaseConstant.kName : name,
                    FireBaseConstant.korigin : location,
                    FireBaseConstant.ksocialUrl : webaddress]
        ref.child(UserNode).child(DataManager.userId!).updateChildValues(dict)
    }
    
    func updateImage(imageUrl : String){
        let dict = [FireBaseConstant.kPhotoUrl : imageUrl]
        DataManager.UserImageURL = imageUrl
        ref.child(UserNode).child(DataManager.userId!).updateChildValues(dict)
    }
    
    func getUserProfileDetail(userid : String,completion: @escaping (Bool) -> Void){
        ref.child(UserNode).child(userid).observeSingleEvent(of: .value) { (userSanpShot) in
            if let userData = userSanpShot.value as? NSDictionary{
                let location = userData[FireBaseConstant.korigin] as? String ?? "Not Provided"
                let socialUrl = userData[FireBaseConstant.ksocialUrl] as? String ?? "Not Provided"
                self.userAddress = UserLocationAndWeb(location: location, webAddress: socialUrl)
                completion(true)
            }
        }
    }

    func reportUser(otherUserDetail : UserDetail){
        let repotedByUser = [FireBaseConstant.kEmail: DataManager.email!,
                          FireBaseConstant.kName: DataManager.name!,
                          FireBaseConstant.kNameForSearch: DataManager.name!.uppercased(),
                          FireBaseConstant.kUid: DataManager.userId!]
        let reporteduser =  [FireBaseConstant.kEmail: otherUserDetail.email,
                             FireBaseConstant.kName: otherUserDetail.name,
                             FireBaseConstant.kNameForSearch: otherUserDetail.name.uppercased(),
                             FireBaseConstant.kUid: otherUserDetail.uid]
        let dict = ["ReportedBy": repotedByUser,
                    "ReportedTo" : reporteduser] as [String : Any]
        ref.child(ReportedUers).child(otherUserDetail.uid).child(DataManager.userId!).setValue(dict)
    }
    
    func reportPost( Pinid : PinsSnapShot){
        let repotedByUser = [FireBaseConstant.kEmail: DataManager.email!,
                             FireBaseConstant.kName: DataManager.name!,
                             FireBaseConstant.kNameForSearch: DataManager.name!.uppercased(),
                             FireBaseConstant.kUid: DataManager.userId!]
        let reportedPin =  [FireBaseConstant.kKey: Pinid.key,
                             FireBaseConstant.kType: Pinid.type,
                             FireBaseConstant.kTitle: Pinid.title,
                             FireBaseConstant.kUser: Pinid.user.uid,
                             FireBaseConstant.kName: Pinid.user.name]
        let dict = ["ReportedBy": repotedByUser,
                    "ReportedPin" : reportedPin] as [String : Any]
        ref.child(PostReported).child(Pinid.key).child(DataManager.userId!).setValue(dict)
    }
    
    
    func blockUser(blockedUser: UserDetail){
        let reporteduser =  [FireBaseConstant.kEmail: blockedUser.email,
                             FireBaseConstant.kName: blockedUser.name,
                             FireBaseConstant.kNameForSearch: blockedUser.name.uppercased(),
                             FireBaseConstant.kPhotoUrl : blockedUser.photoUrl,
                             FireBaseConstant.kUid: blockedUser.uid]
        
        let repotedByUser = [FireBaseConstant.kEmail: DataManager.email!,
                             FireBaseConstant.kName: DataManager.name!,
                             FireBaseConstant.kNameForSearch: DataManager.name!.uppercased(),
                             FireBaseConstant.kPhotoUrl : DataManager.UserImageURL,
                             FireBaseConstant.kUid: DataManager.userId!]
        
        
        ref.child(UserNode).child(DataManager.userId!).child(FireBaseConstant.kBlockedTo).child(blockedUser.uid).setValue(reporteduser)
        ref.child(UserNode).child(blockedUser.uid).child(FireBaseConstant.kBlockBy).child(DataManager.userId!).setValue(repotedByUser)
    }
    
    
    func checkIsBlockedByMe(otherUser : UserDetail,completion: @escaping (Bool) -> Void){
        ref.child(UserNode).child(DataManager.userId!).child(FireBaseConstant.kBlockedTo).child(otherUser.uid).observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.exists(){
                completion(true)
            }else{
                self.checkIsBlockedByOther(otherUser: otherUser, completion: { (success) in
                    completion(success)
                })
                //completion(false)
            }
            
        }
    }
    
    func checkIsBlockedByOther(otherUser : UserDetail,completion: @escaping (Bool) -> Void){
        ref.child(UserNode).child(otherUser.uid).child(FireBaseConstant.kBlockedTo).child(DataManager.userId!).observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.exists(){
                completion(true)
            }else{
                completion(false)
            }
            
        }
    }
    
    func removeFromBlockList(blockedUser :  UserDetail){
        ref.child(UserNode).child(DataManager.userId!).child(FireBaseConstant.kBlockedTo).child(blockedUser.uid).removeValue()
        ref.child(UserNode).child(blockedUser.uid).child(FireBaseConstant.kBlockBy).child(DataManager.userId!).removeValue()
    }
    
    func getBlockList(completion: @escaping (Bool) -> Void){
        ref.child(UserNode).child(DataManager.userId!).child(FireBaseConstant.kBlockedTo).observeSingleEvent(of: .value) { (snapShot) in
            print(snapShot)
            let children = snapShot.children.allObjects
            for child in children{
                if let childSnapshot = child as? DataSnapshot{
                    let childDict = childSnapshot.value as! NSDictionary
                    let email = childDict[FireBaseConstant.kEmail] as? String ?? ""
                    let name1 = childDict[FireBaseConstant.kName] as? String ?? ""
                    let photoUrl = childDict[FireBaseConstant.kPhotoUrl] as? String ?? ""
                    let uid = childDict[FireBaseConstant.kUid] as? String ?? ""
                    let fcmToken = childDict[FireBaseConstant.kToken] as? String ?? ""
                    self.blockedList.append(UserDetail(name: name1, email: email, photoUrl: photoUrl, uid: uid, fcmToken: fcmToken))
                }
            }
            completion(true)
        }
    }
}
