//
//  UpdatePinsVM.swift
//  Something
//
//  Created by Maninder Singh on 23/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import CoreLocation
import Alamofire
import UserNotifications

class UpdatePinVM {
    
    private init(){}
    static let shared = UpdatePinVM()
    let ref : DatabaseReference = Database.database().reference()
    private var count = 0
    
    var pinsFeed = [PinFeed]()
    var notifications = [AppNotification]()
    
    func updatePinVisited(pin: PinsSnapShot){
        let userActivityDict = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                FireBaseConstant.kPin : [FireBaseConstant.kKey: pin.key,
                                                         FireBaseConstant.kTitle: pin.title,
                                                         FireBaseConstant.kType: pin.type],
                                FireBaseConstant.kType : 2] as [String : Any]
        ref.child(UserActivity).child(DataManager.userId!).childByAutoId().setValue(userActivityDict)
        let ref1 = ref.child(UserWishList).child(DataManager.userId!).child(pin.key).ref
        ref1.removeValue()
        let ref2 = ref.child(UserMissedPins).child(DataManager.userId!).child(pin.key).ref
        ref2.removeValue()
        let pinActivity = [FireBaseConstant.kDate : [".sv": "timestamp"],
                           FireBaseConstant.kType : 2,
                           FireBaseConstant.kUser : MyUserDetail] as [String : Any]
        ref.child(PinActivity).child(pin.key).childByAutoId().setValue(pinActivity)
        
        ref.child(PinVisitedBy).child(pin.key).updateChildValues([DataManager.userId! : [".sv": "timestamp"]])
        ref.child(VisitedPin).child(DataManager.userId!).setValue([ pin.key : true])
        let updateNotification = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                  FireBaseConstant.kType : 1,
                                  FireBaseConstant.kTitle : DataManager.name ?? DataManager.email!,
                                  FireBaseConstant.kPin : [FireBaseConstant.kKey : pin.key,
                                                           FireBaseConstant.kTitle: pin.title,
                                                           FireBaseConstant.kType : pin.type],
                                  FireBaseConstant.kUser : MyUserDetail] as [String : Any]
        self.ref.child(Pins).child(pin.key).updateChildValues([FireBaseConstant.kVisitedCount : pin.visitedCount + 1])
        self.ref.child(UserNotifications).child(DataManager.userId!).childByAutoId().setValue(updateNotification)
       
                self.ref.child(UserFcmIds).child(pin.user.uid).observe(.value) { (snap) in
                    if let valuedict = snap.value as? NSDictionary{
                        let fcmIds = valuedict.allKeys
                        for key in fcmIds{
                            if key is String{
                                self.sendNotification(senderId: key as! String, title: pin.title, body: "\(pin.title) is visited by \(DataManager.name ?? DataManager.email!)")
                            }
                        }
                    }
                }
    }
    
    func giveRating(pin: PinsSnapShot,rating : CGFloat){
        isRatingExists(pinId: pin.key) { (success) in
            if !success{
                self.ref.child(UserFcmIds).child(pin.user.uid).observe(.value) { (snap) in
                    if let valuedict = snap.value as? NSDictionary{
                        let fcmIds = valuedict.allKeys
                        for key in fcmIds{
                            if key is String{
                                self.sendNotification(senderId: key as! String, title: pin.title, body: "Rating is given by \(DataManager.name ?? DataManager.email!)")
                            }
                        }
                    }
                }
                let newRatingTimes = pin.ratedTimes + 1
                let newRating = (pin.rating + Int(rating)) / newRatingTimes
                self.ref.child(Pins).child(pin.key).updateChildValues([FireBaseConstant.kRatedTimes : newRatingTimes,
                                                                       FireBaseConstant.kRating : newRating])
            }
        }
        
        let userActivityDict = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                FireBaseConstant.kPin : [FireBaseConstant.kKey: pin.key,
                                                         FireBaseConstant.kTitle: pin.title,
                                                         FireBaseConstant.kType: pin.type],
                                FireBaseConstant.kType : 3] as [String : Any]
        ref.child(UserActivity).child(DataManager.userId!).childByAutoId().setValue(userActivityDict)
        let pinsUserRatingDict = [DataManager.userId!: rating]
        ref.child(PinUserRating).child(pin.key).setValue(pinsUserRatingDict)
        let pinActivity = [FireBaseConstant.kDate : [".sv": "timestamp"],
                           FireBaseConstant.kType : 3,
                           FireBaseConstant.kUser : MyUserDetail] as [String : Any]
        ref.child(PinActivity).child(pin.key).childByAutoId().setValue(pinActivity)
        let updateNotification = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                  FireBaseConstant.kType : 2,
                                  FireBaseConstant.kTitle : DataManager.name ?? DataManager.email!,
                                  FireBaseConstant.kPin : [FireBaseConstant.kKey : pin.key,
                                                           FireBaseConstant.kTitle: pin.title,
                                                           FireBaseConstant.kType : pin.type],
                                  FireBaseConstant.kUser : MyUserDetail] as [String : Any]
        self.ref.child(UserNotifications).child(DataManager.userId!).childByAutoId().setValue(updateNotification)
        
        
        
    }
    
    func isRatingExists(pinId : String,completion: @escaping (Bool) -> Void){
        ref.child(PinUserRating).child(pinId).queryOrderedByKey().queryEqual(toValue: pinId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func getPinsFeeds(pidId: String,completion: @escaping (Bool) -> Void){
        ref.child(PinActivity).child(pidId).observeSingleEvent(of: .value) { (snapShot) in
            self.pinsFeed.removeAll()
            let children = snapShot.children
            for child in children{
                if let snapShotDict = child as? DataSnapshot{
                    if let value = snapShotDict.value as? NSDictionary{
                        let date = value[FireBaseConstant.kDate] as? Int ?? 0
                        let type = value[FireBaseConstant.kType] as? Int ?? 0
                        var user : UserDetail!
                        if let userDict = value[FireBaseConstant.kUser] as? NSDictionary{
                            user =  UserVM.shared.parasUserDetail(user: userDict)
                        }
                        self.pinsFeed.append(PinFeed(date: date, type: type, user: user))
                    }
                }
            }
            completion(true)
        }
    }
    
    func isPinVisited(pinId : String ,completion: @escaping (Bool) -> Void){
        if DataManager.isLogin!{
            ref.child(VisitedPin).child(DataManager.userId!).queryOrderedByKey().queryEqual(toValue: pinId).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(){
                    completion(true)
                }else{
                    completion(false)
                }
                
            }
        }
       
    }
    
    func isMissedPin(pinId : String ,completion: @escaping (Bool) -> Void){
        ref.child(UserMissedPins).child(DataManager.userId!).queryOrderedByKey().queryEqual(toValue: pinId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func getnotifications(completion: @escaping (Bool) -> Void){
        ref.child(UserNotifications).child(DataManager.userId!).observeSingleEvent(of: .value) { (snapShot) in
            let children = snapShot.children
            while let rest = children.nextObject() as? DataSnapshot{
                if let restDict = rest.value as? NSDictionary{
                    let key = rest.key
                    let date = restDict[FireBaseConstant.kDate] as? Int ?? 0
                    let type = restDict[FireBaseConstant.kType] as? Int ?? 0
                    let title = restDict[FireBaseConstant.kTitle] as? String ?? ""
                    var user : UserDetail?
                    if let userDict = restDict[FireBaseConstant.kUser] as? NSDictionary{
                        user =  UserVM.shared.parasUserDetail(user: userDict)
                    }
                    var pin = Pin()
                    if let pinDict = restDict[FireBaseConstant.kPin] as? NSDictionary{
                        let key = pinDict[FireBaseConstant.kKey] as? String ?? ""
                        let title = pinDict[FireBaseConstant.kTitle] as? String ?? ""
                        let type = pinDict[FireBaseConstant.kType] as? String ?? ""
                        pin = Pin(key: key, title: title, type: type)
                    }
                    self.notifications.append(AppNotification(key : key ,date: date, title: title, type: type, pin: pin, user: user))
                }
            }
            completion(true)
        }
    }
    
    func deleteNotification(key : String){
        let ref1 = ref.child(UserNotifications).child(DataManager.userId!).child(key).ref
        ref1.removeValue()
    }
    
    func addSponser(pinID: String, url : URL){
        
        ref.child(Pins).child(pinID).observeSingleEvent(of: .value) { (snapShot) in
        if let restDict = snapShot.value as? NSDictionary{
            
                
                var sponser = [NSDictionary]()
            
                if let mediaArr_sponser = restDict[FireBaseConstant.kSponser] as? [NSDictionary]{
                    
                    for data_sponser in mediaArr_sponser{
                        
                        let name = data_sponser[FireBaseConstant.kName] as? String ?? ""
                        let thumbnailName = data_sponser[FireBaseConstant.kThumbnailName] as? String ?? ""
                        let type = data_sponser[FireBaseConstant.kType] as? String ?? ""
                        let uri = data_sponser[FireBaseConstant.kUri] as? String ?? ""
                        
                        let dict = [FireBaseConstant.kName : name,
                                    FireBaseConstant.kThumbnailName : thumbnailName,
                                    FireBaseConstant.kType: type,
                                    FireBaseConstant.kUri : uri]
                        sponser.append(dict as NSDictionary)
                    }
                    
                }
                let dict_new = [FireBaseConstant.kName : url.lastPathComponent,
                                FireBaseConstant.kThumbnailName : url.lastPathComponent,
                                FireBaseConstant.kType: "IMAGE",
                                FireBaseConstant.kUri : url.absoluteString]
            
                sponser.append(dict_new as NSDictionary)
                self.ref.child(Pins).child(pinID).updateChildValues([FireBaseConstant.kSponser : sponser])
            
            }
        }

            
        
        
    }
    
    func deletePin(pin : PinsSnapShot){
        let userActivityDict = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                FireBaseConstant.kPin : [FireBaseConstant.kKey: pin.key,
                                                         FireBaseConstant.kTitle: pin.title,
                                                         FireBaseConstant.kType: pin.type],
                                FireBaseConstant.kType : 7] as [String : Any]
        ref.child(UserActivity).child(DataManager.userId!).childByAutoId().setValue(userActivityDict)
        let ref1 = ref.child(Pins).child(pin.key).ref
        ref1.removeValue()
    }
    
    func updateUserPinNote(key : String, title : String, pinType: String, description: String , notes: String , videoLink: String, pinLocation: CLLocationCoordinate2D , urls : [URL]){
        // Update user-pin
        let refLink = ref.child(UserPin).child(DataManager.userId!).child(key)
        
        //Update pin-activity
        let pinActivity = [FireBaseConstant.kDate : [".sv": "timestamp"],
                           FireBaseConstant.kType : 0,
                           FireBaseConstant.kUser : MyUserDetail] as [String : Any]
        ref.child(PinActivity).child(refLink.key!).childByAutoId().setValue(pinActivity)
        
        
        //Update User-Acrivity
        
        let activityType1 = [FireBaseConstant.kDate: [".sv": "timestamp"],
                             FireBaseConstant.kType : 6,
                             FireBaseConstant.kPin : [FireBaseConstant.kKey : key,
                                                      FireBaseConstant.kTitle: title,
                                                      FireBaseConstant.kType : pinType]] as [String : Any]
        ref.child(UserActivity).child(DataManager.userId!).childByAutoId().setValue(activityType1)
        
        
        //Update pin
        let geoCord = [FireBaseConstant.kLat: pinLocation.latitude,
                       FireBaseConstant.kLong: pinLocation.longitude]
        
        var media = [NSDictionary]()
        for data in urls{
            let dict = [FireBaseConstant.kName : data.lastPathComponent,
                        FireBaseConstant.kThumbnailName : data.lastPathComponent,
                        FireBaseConstant.kType: "IMAGE",
                        FireBaseConstant.kUri : data.absoluteString]
            media.append(dict as NSDictionary)
        }
        
        let pinData = [FireBaseConstant.kCreationTime : [".sv": "timestamp"],
                       FireBaseConstant.kDescription : description,
                       FireBaseConstant.kKey: refLink.key,
                       FireBaseConstant.kNotes : notes,
                       FireBaseConstant.kVideoLink : videoLink,
                       //FireBaseConstant.kRatedTimes : 0,
                      // FireBaseConstant.kRating : 0,
                       FireBaseConstant.kTitle: title,
                       FireBaseConstant.kType: pinType,
                      // FireBaseConstant.kVisitedCount :0,
                       FireBaseConstant.kMedia : media,
                      // FireBaseConstant.kUser: MyUserDetail,
                       FireBaseConstant.kCoordinates: geoCord] as [String : Any]
        ref.child(Pins).child(refLink.key!).updateChildValues(pinData)
        
    }
    
    func addToMissedPin(pinId: String){
       
        ref.child(Pins).child(pinId).observeSingleEvent(of: .value) { (snapShot) in
            if let restDict = snapShot.value as? NSDictionary{
                let title = restDict[FireBaseConstant.kTitle] as? String ?? ""
                let type = restDict[FireBaseConstant.kType] as? String ?? ""
                var userdUid = String()
                if let userDict = restDict[FireBaseConstant.kUser] as? NSDictionary{
                    userdUid = userDict[FireBaseConstant.kUid] as? String ?? ""
                }
                if userdUid != DataManager.userId!{
                    self.isMissedPin(pinId: pinId) { (success) in
                        if !success{
                            let updateNotification = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                                      FireBaseConstant.kType : 0,
                                                      FireBaseConstant.kTitle : title,
                                                      FireBaseConstant.kPin : [FireBaseConstant.kKey : pinId,
                                                                               FireBaseConstant.kTitle: title,
                                                                               FireBaseConstant.kType : type],
                                                      FireBaseConstant.kUser : MyUserDetail] as [String : Any]
                            self.ref.child(UserNotifications).child(DataManager.userId!).childByAutoId().setValue(updateNotification)
                            self.ref.child(UserMissedPins).child(DataManager.userId!).updateChildValues([pinId : true])
                            self.fireLocalNotificiation(title: title, body: "\(title) is not so far away.")
                            self.ref.child(UserFcmIds).child(DataManager.userId!).observe(.value) { (snap) in
                                if let valuedict = snap.value as? NSDictionary{
                                    let fcmIds = valuedict.allKeys
                                    for key in fcmIds{
                                        if key is String{
                                            self.sendNotification(senderId: key as! String, title: title, body: "\(title) is not so far away.")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fireLocalNotificiation(title : String, body: String){
        if #available(iOS 10.0, *) {
            //iOS 10 or above version
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = "alarm"
            content.sound = UNNotificationSound.default()
            //let comp = Calendar.current.dateComponents([.hour, .minute], from: Date())
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        } else {
            // ios 9
            let notification = UILocalNotification()
            notification.fireDate = Date()
            notification.alertBody = body
            notification.alertAction = title
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    
    func sendNotification(senderId : String, title : String , body: String){
        let uRL = URL(string: "https://fcm.googleapis.com/fcm/send")
        let headers = ["Content-Type": "application/json",
            "Authorization": "key=AAAAuft_C-w:APA91bHe3aJwdKoBLDozpCZH3c1D61obcAWXHBu9yJFU1TgV53Pfyv_yLl4u9LqtC4QDqpvaXB_T8v_mW3pOK_AuIhlIGPW65Oe0ygKabT72E7fapLorJQqmt32RwqGtLOnmpDly5fSj"]
        
        let parameters = ["to": senderId,
                          "priority": "high",
                          "notification": ["body": body,
                                           "title": title],
                          "data": ["message" : body]] as [String : Any]
        Alamofire.request(uRL!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
           print("asdfas")
        }
    }
}
