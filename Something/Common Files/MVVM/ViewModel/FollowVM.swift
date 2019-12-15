//
//  FollowVM.swift
//  Something
//
//  Created by Maninder Singh on 02/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation


class FollowVM{
    
    private init(){}
    static let shared = FollowVM()
    let ref : DatabaseReference = Database.database().reference()
    private var count = 0
    
    var follower = [UserDetail]()
    var following = [UserDetail]()
    
    func getUserDetail(userId : String, completion: @escaping (UserDetail) -> Void){
        ref.child(UserNode).child(userId).observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.exists(){
                let user = UserVM.shared.parasUserDetail(user: snapShot.value as! NSDictionary)
                completion(user)
            }else{
                print("no user exits")
            }
        }
    }
    
    
    func searchForFollow(userId : String,ValueExists : @escaping (Bool) -> Void){
        ref.child(UserSubscriptions).child(DataManager.userId!).queryOrderedByKey().queryEqual(toValue: userId).observe(.value) { (snapshot) in
            if snapshot.exists(){
                ValueExists(true)
            }else{
                ValueExists(false)
            }
        }
    }
    
    func suscribeUser(userId : String){
        ref.child(UserSubscriptions).child(DataManager.userId!).updateChildValues([userId : true])
        ref.child(UserSubscribers).child(userId).updateChildValues([DataManager.userId!: true])
    }
    
    func unSuscribeUser(userId : String){
        let ref1 = ref.child(UserSubscriptions).child(DataManager.userId!).child(userId).ref
        ref1.removeValue()
        let ref2 = ref.child(UserSubscribers).child(userId).child(DataManager.userId!).ref
        ref2.removeValue()
    }
    
}
