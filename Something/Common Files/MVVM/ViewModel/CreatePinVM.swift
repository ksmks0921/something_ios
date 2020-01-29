//
//  CreatePinVM.swift
//  Something
//
//  Created by Maninder Singh on 28/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation


class CreatePinVM{
    
    private init(){}
    static let shared = CreatePinVM()
    let ref : DatabaseReference = Database.database().reference()
    private var count = 0
    
    var pinsData = [PinsSnapShot]()
    
    var searchedpinsData = [PinsSnapShot]()
    
    var userPins = [UserPinsDetail]()
    var visitedPins = [UserPinsDetail]()
    var wishList = [UserPinsDetail]()
    var missedPins = [UserPinsDetail]()
    var pinVisitedUsers = [PinVisitedByUsers]()
    var pinComments = [PinComment]()
    var userFeeds = [UserFeed]()
    
    func setUpUserPinNote(title : String, pinType: String, activityType : Int, description: String , notes: String, videoLink : String , pinLocation: CLLocationCoordinate2D , urls : [URL]){
        // Update user-pin
        let refLink = ref.child(UserPin).child(DataManager.userId!).childByAutoId()
        refLink.setValue(refLink.key)
        
        //Update User-Acrivity
        
        let pinDetail = [FireBaseConstant.kKey : refLink.key,
                         FireBaseConstant.kTitle: title,
                         FireBaseConstant.kType : pinType]
        let activityType1 = [FireBaseConstant.kDate: [".sv": "timestamp"],
                            FireBaseConstant.kType : activityType,
                            FireBaseConstant.kPin : pinDetail] as [String : Any]
        let userActivityNote  = ref.child(UserActivity).child(DataManager.userId!).childByAutoId()
        userActivityNote.setValue(activityType1)
        
        //Update pin-activity
        let pinActivity = [FireBaseConstant.kDate : [".sv": "timestamp"],
                           FireBaseConstant.kType : 0,
                           FireBaseConstant.kUser : MyUserDetail] as [String : Any]
        ref.child(PinActivity).child(refLink.key!).childByAutoId().setValue(pinActivity)
        
        //geofire
        let geoHash = GFGeoHash.init(location: pinLocation).geoHashValue
        let geoDict = ["g":geoHash!,
                       "l": [pinLocation.latitude,pinLocation.longitude]] as [String : Any]
        ref.child(PinsGeofire).child(refLink.key!).setValue(geoDict)
        
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
                       FireBaseConstant.kRatedTimes : 0,
                       FireBaseConstant.kRating : 0,
                       FireBaseConstant.kTitle: title,
                       FireBaseConstant.kType: pinType,
                       FireBaseConstant.kVisitedCount :0,
                       FireBaseConstant.kMedia : media,
                       FireBaseConstant.kUser: MyUserDetail,
                       FireBaseConstant.kCoordinates: geoCord] as [String : Any]
        ref.child(Pins).child(refLink.key!).setValue(pinData)
        
    }
    
    func getPins( completion: @escaping (Bool) -> Void){
        
        ref.child(Pins).observe(.value) { (snapShot) in
            let children = snapShot.children
            self.pinsData.removeAll()
            while let rest = children.nextObject() as? DataSnapshot {
                if let restDict = rest.value as? NSDictionary{
                    
                    let creationTime = restDict[FireBaseConstant.kCreationTime] as? Int ?? 0
                    let description = restDict[FireBaseConstant.kDescription] as? String ?? ""
                    let key = restDict[FireBaseConstant.kKey] as? String ?? ""
                    let notes = restDict[FireBaseConstant.kNotes] as? String ?? ""
                    let videoLink = restDict[FireBaseConstant.kVideoLink] as? String ?? ""
                    let ratedTimes = restDict[FireBaseConstant.kRatedTimes] as? Int ?? 0
                    let rating = restDict[FireBaseConstant.kRating] as? Int ?? 0
                    let title = restDict[FireBaseConstant.kTitle] as? String ?? ""
                    let type = restDict[FireBaseConstant.kType] as? String ?? ""
                    let visitedCount = restDict[FireBaseConstant.kVisitedCount] as? Int ?? 0
                    var myUserdict = UserDetail(name: "", email: "", photoUrl: "", uid: "", fcmToken: "")
                    if let userDict = restDict[FireBaseConstant.kUser] as? NSDictionary{
                        let email = userDict[FireBaseConstant.kEmail] as? String ?? ""
                        let name = userDict[FireBaseConstant.kName] as? String ?? ""
                        let nameForSearch = userDict[FireBaseConstant.kNameForSearch] as? String ?? ""
                        let photoUrl = userDict[FireBaseConstant.kPhotoUrl] as? String ?? ""
                        let uid = userDict[FireBaseConstant.kUid] as? String ?? ""
                        let fcmToken = userDict[FireBaseConstant.kToken] as? String ?? ""
                        myUserdict = UserDetail(name: name, email: email, photoUrl: photoUrl, uid: uid, fcmToken: fcmToken)
                    }
                    var mediaA = [PinMedia]()
                    if let mediaArr = restDict[FireBaseConstant.kMedia] as? [NSDictionary]{
                        for data in mediaArr{
                            let name = data[FireBaseConstant.kName] as? String ?? ""
                            let thumbnailName = data[FireBaseConstant.kThumbnailName] as? String ?? ""
                            let type = data[FireBaseConstant.kType] as? String ?? ""
                            let uri = data[FireBaseConstant.kUri] as? String ?? ""
                            let mediaData = PinMedia(name: name, thumbnailName: thumbnailName, type: type, uri: uri)
                            mediaA.append(mediaData)
                        }
                    }
                    var coordinate = Coordinates(lat: 0.0, lon: 0.0)
                    if let  coordinatesDict = restDict[FireBaseConstant.kCoordinates] as? NSDictionary{
                        let lat = coordinatesDict[FireBaseConstant.kLat] as? Double ?? 0.0
                        let long = coordinatesDict[FireBaseConstant.kLong] as? Double ?? 0.0
                        coordinate = Coordinates(lat: lat, lon: long)
                    }
                    let locationLatLong = CLLocation(latitude: coordinate.lat, longitude: coordinate.lon)
                    let distance = locationLatLong.distance(from: CLLocation(latitude: globleCurrentLocation.latitude, longitude: globleCurrentLocation.longitude))
                    let yard = Int(distance / 1.09361)
                    self.pinsData.append(PinsSnapShot(coordinates: coordinate, description: description, key: key, media: mediaA, notes: notes, videoLink: videoLink, ratedTimes: ratedTimes, rating: rating, title: title, type: type, user: myUserdict, visitedCount: visitedCount, ditance: yard, creationTime: creationTime))
                }
            }
            let filertedPin = self.pinsData.filter({ (pinData) -> Bool in
                return pinData.ditance < 200000
            })
            let sortedData = filertedPin.sorted(by: { $0.ditance < $1.ditance })
        
            self.pinsData = sortedData
            completion(true)
        }
    }
    
    func searchForFav(pinId : String,ValueExists : @escaping (Bool) -> Void){
        
//        ref.child(UserWishList).child(DataManager.userId!).queryOrderedByKey().queryEqual(toValue: pinId).observe(.value) { (snapshot) in
//            if snapshot.exists(){
//                ValueExists(true)
//            }else{
//                ValueExists(false)
//            }
//        }
    }
    
    func AddwishList(pinId : String){
        ref.child(UserWishList).child(DataManager.userId!).updateChildValues([pinId : true])
    }
    
    func removeFromWishList(pinId : String){
        let ref1 = ref.child(UserWishList).child(DataManager.userId!).child(pinId).ref
        ref1.removeValue()
    }
    
    func getCreatedPins(userid : String,completion: @escaping (Bool) -> Void){
        ref.child(UserPin).child(userid).observeSingleEvent(of: .value) { (snapShot) in
            self.userPins.removeAll()
            let dict = snapShot.value as? NSDictionary
            if let idArr = dict?.allKeys{
                self.count = idArr.count
                if self.count == 0{
                    completion(true)
                }
                for item in idArr{
                    self.getSpecificPinDetail(pinId: item as! String, TypeOfWS: "created", completion: { users in
                        self.count = self.count - 1
                        
                        if self.count == 0{
                            completion(true)
                        }
                    })
                    
                }
            }else{
                completion(true)
                print("no followers")
            }
        }
    }
    
    func getSearchedPins(key : String,completion: @escaping (Bool) -> Void){
        print("_______Hey! key is ________" + key)
        ref.child(Pins).observe(.value) { (snapShot) in
            let children = snapShot.children
            self.searchedpinsData.removeAll()
            while let rest = children.nextObject() as? DataSnapshot {
                if let restDict = rest.value as? NSDictionary{
                    let title_for_search = restDict[FireBaseConstant.kTitle] as? String ?? ""
                    if title_for_search.contains(key){
                        
                        let creationTime = restDict[FireBaseConstant.kCreationTime] as? Int ?? 0
                            let description = restDict[FireBaseConstant.kDescription] as? String ?? ""
                            let key = restDict[FireBaseConstant.kKey] as? String ?? ""
                            let notes = restDict[FireBaseConstant.kNotes] as? String ?? ""
                            let videoLink = restDict[FireBaseConstant.kVideoLink] as? String ?? ""
                            let ratedTimes = restDict[FireBaseConstant.kRatedTimes] as? Int ?? 0
                            let rating = restDict[FireBaseConstant.kRating] as? Int ?? 0
                            let title = restDict[FireBaseConstant.kTitle] as? String ?? ""
                            let type = restDict[FireBaseConstant.kType] as? String ?? ""
                            let visitedCount = restDict[FireBaseConstant.kVisitedCount] as? Int ?? 0
                            var myUserdict = UserDetail(name: "", email: "", photoUrl: "", uid: "", fcmToken: "")
                            if let userDict = restDict[FireBaseConstant.kUser] as? NSDictionary{
                                let email = userDict[FireBaseConstant.kEmail] as? String ?? ""
                                let name = userDict[FireBaseConstant.kName] as? String ?? ""
                                let nameForSearch = userDict[FireBaseConstant.kNameForSearch] as? String ?? ""
                                let photoUrl = userDict[FireBaseConstant.kPhotoUrl] as? String ?? ""
                                let uid = userDict[FireBaseConstant.kUid] as? String ?? ""
                                let fcmToken = userDict[FireBaseConstant.kToken] as? String ?? ""
                                myUserdict = UserDetail(name: name, email: email, photoUrl: photoUrl, uid: uid, fcmToken: fcmToken)
                            }
                            var mediaA = [PinMedia]()
                            if let mediaArr = restDict[FireBaseConstant.kMedia] as? [NSDictionary]{
                                for data in mediaArr{
                                    let name = data[FireBaseConstant.kName] as? String ?? ""
                                    let thumbnailName = data[FireBaseConstant.kThumbnailName] as? String ?? ""
                                    let type = data[FireBaseConstant.kType] as? String ?? ""
                                    let uri = data[FireBaseConstant.kUri] as? String ?? ""
                                    let mediaData = PinMedia(name: name, thumbnailName: thumbnailName, type: type, uri: uri)
                                    mediaA.append(mediaData)
                                }
                            }
                            var coordinate = Coordinates(lat: 0.0, lon: 0.0)
                            if let  coordinatesDict = restDict[FireBaseConstant.kCoordinates] as? NSDictionary{
                                let lat = coordinatesDict[FireBaseConstant.kLat] as? Double ?? 0.0
                                let long = coordinatesDict[FireBaseConstant.kLong] as? Double ?? 0.0
                                coordinate = Coordinates(lat: lat, lon: long)
                            }
                            let locationLatLong = CLLocation(latitude: coordinate.lat, longitude: coordinate.lon)
                            let distance = locationLatLong.distance(from: CLLocation(latitude: globleCurrentLocation.latitude, longitude: globleCurrentLocation.longitude))
                            let yard = Int(distance / 1.09361)
                            self.searchedpinsData.append(PinsSnapShot(coordinates: coordinate, description: description, key: key, media: mediaA, notes: notes, videoLink: videoLink, ratedTimes: ratedTimes, rating: rating, title: title, type: type, user: myUserdict, visitedCount: visitedCount, ditance: yard, creationTime: creationTime))
                        }
                    
                    
                    }
                    
            }
           
            completion(true)
        }
        
    }
    func getVisitedPins(userid : String,completion: @escaping (Bool) -> Void){
        ref.child(VisitedPin).child(userid).observeSingleEvent(of: .value) { (snapShot) in
            self.visitedPins.removeAll()
            let dict = snapShot.value as? NSDictionary
            if let idArr = dict?.allKeys{
                self.count = idArr.count
                if self.count == 0{
                    completion(true)
                }
                for item in idArr{
                    self.getSpecificPinDetail(pinId: item as! String, TypeOfWS: "visited", completion: { users in
                        self.count = self.count - 1
                        
                        if self.count == 0{
                            completion(true)
                        }
                    })
                    
                }
            }else{
                completion(true)
                print("no followers")
            }
        }
    }
    
    func getMissedPins(userid : String,completion: @escaping (Bool) -> Void){
        ref.child(UserMissedPins).child(userid).observeSingleEvent(of: .value) { (snapShot) in
            self.missedPins.removeAll()
            let dict = snapShot.value as? NSDictionary
            if let idArr = dict?.allKeys{
                self.count = idArr.count
                if self.count == 0{
                    completion(true)
                }
                for item in idArr{
                    self.getSpecificPinDetail(pinId: item as! String, TypeOfWS: "missed", completion: { users in
                        self.count = self.count - 1
                        
                        if self.count == 0{
                            completion(true)
                        }
                    })
                    
                }
            }else{
                completion(true)
                print("no followers")
            }
        }
    }
    
    func getWishedPins(userid : String,completion: @escaping (Bool) -> Void){
        ref.child(UserWishList).child(userid).observeSingleEvent(of: .value) { (snapShot) in
            self.wishList.removeAll()
            let dict = snapShot.value as? NSDictionary
            if let idArr = dict?.allKeys{
                self.count = idArr.count
                if self.count == 0{
                    completion(true)
                }
                for item in idArr{
                    self.getSpecificPinDetail(pinId: item as! String, TypeOfWS: "wishList", completion: { users in
                        self.count = self.count - 1
                        
                        if self.count == 0{
                            completion(true)
                        }
                    })
                    
                }
            }else{
                completion(true)
                print("no followers")
            }
        }
    }
    
    func getSpecificPinDetail(pinId : String,TypeOfWS : String ,completion: @escaping (Bool) -> Void){
        ref.child(Pins).child(pinId).observeSingleEvent(of: .value) { (snapShot) in
                if let restDict = snapShot.value as? NSDictionary{
                    let creationTime = restDict[FireBaseConstant.kCreationTime] as? Int ?? 0
                    let description = restDict[FireBaseConstant.kDescription] as? String ?? ""
                    let key = restDict[FireBaseConstant.kKey] as? String ?? ""
                    let notes = restDict[FireBaseConstant.kNotes] as? String ?? ""
                    let videoLink = restDict[FireBaseConstant.kVideoLink] as? String ?? ""
                    let ratedTimes = restDict[FireBaseConstant.kRatedTimes] as? Int ?? 0
                    let rating = restDict[FireBaseConstant.kRating] as? Int ?? 0
                    let title = restDict[FireBaseConstant.kTitle] as? String ?? ""
                    let type = restDict[FireBaseConstant.kType] as? String ?? ""
                    let visitedCount = restDict[FireBaseConstant.kVisitedCount] as? Int ?? 0
                    var myUserdict = UserDetail(name: "", email: "", photoUrl: "", uid: "", fcmToken: "")
                    if let userDict = restDict[FireBaseConstant.kUser] as? NSDictionary{
                        let email = userDict[FireBaseConstant.kEmail] as? String ?? ""
                        let name = userDict[FireBaseConstant.kName] as? String ?? ""
                        let nameForSearch = userDict[FireBaseConstant.kNameForSearch] as? String ?? ""
                        let photoUrl = userDict[FireBaseConstant.kPhotoUrl] as? String ?? ""
                        let uid = userDict[FireBaseConstant.kUid] as? String ?? ""
                        let fcmToken = userDict[FireBaseConstant.kToken] as? String ?? ""
                        myUserdict = UserDetail(name: name, email: email, photoUrl: photoUrl, uid: uid, fcmToken: fcmToken)
                    }
                    var mediaA = [PinMedia]()
                    if let mediaArr = restDict[FireBaseConstant.kMedia] as? [NSDictionary]{
                        for data in mediaArr{
                            let name = data[FireBaseConstant.kName] as? String ?? ""
                            let thumbnailName = data[FireBaseConstant.kThumbnailName] as? String ?? ""
                            let type = data[FireBaseConstant.kType] as? String ?? ""
                            let uri = data[FireBaseConstant.kUri] as? String ?? ""
                            let mediaData = PinMedia(name: name, thumbnailName: thumbnailName, type: type, uri: uri)
                            mediaA.append(mediaData)
                        }
                    }
                    var coordinate = Coordinates(lat: 0.0, lon: 0.0)
                    if let  coordinatesDict = restDict[FireBaseConstant.kCoordinates] as? NSDictionary{
                        let lat = coordinatesDict[FireBaseConstant.kLat] as? Double ?? 0.0
                        let long = coordinatesDict[FireBaseConstant.kLong] as? Double ?? 0.0
                        coordinate = Coordinates(lat: lat, lon: long)
                    }
                    let locationLatLong = CLLocation(latitude: coordinate.lat, longitude: coordinate.lon)
                    let distance = locationLatLong.distance(from: CLLocation(latitude: globleCurrentLocation.latitude, longitude: globleCurrentLocation.longitude))
                    let yard = Int(distance / 1.09361)
                    if TypeOfWS == "visited"{
                        self.visitedPins.append(UserPinsDetail(pin: PinsSnapShot(coordinates: coordinate, description: description, key: key, media: mediaA, notes: notes, videoLink: videoLink, ratedTimes: ratedTimes, rating: rating, title: title, type: type, user: myUserdict, visitedCount: visitedCount, ditance: yard, creationTime: creationTime)))
                    }
                    if TypeOfWS == "created"{
                        self.userPins.append(UserPinsDetail(pin: PinsSnapShot(coordinates: coordinate, description: description, key: key, media: mediaA, notes: notes, videoLink: videoLink, ratedTimes: ratedTimes, rating: rating, title: title, type: type, user: myUserdict, visitedCount: visitedCount, ditance: yard, creationTime: creationTime)))
                    }
                    if TypeOfWS == "wishList"{
                        self.wishList.append(UserPinsDetail(pin: PinsSnapShot(coordinates: coordinate, description: description, key: key, media: mediaA, notes: notes,videoLink: videoLink, ratedTimes: ratedTimes, rating: rating, title: title, type: type, user: myUserdict, visitedCount: visitedCount, ditance: yard, creationTime: creationTime)))
                    }
                    if TypeOfWS == "missed"{
                        self.missedPins.append(UserPinsDetail(pin: PinsSnapShot(coordinates: coordinate, description: description, key: key, media: mediaA, notes: notes,videoLink: videoLink, ratedTimes: ratedTimes, rating: rating, title: title, type: type, user: myUserdict, visitedCount: visitedCount, ditance: yard, creationTime: creationTime)))
                    }
                    
                }
            completion(true)
        }
    }
    
    
    func getPinCheckedInUsers(pinId : String,completion: @escaping (Bool) -> Void){
        ref.child(PinVisitedBy).child(pinId).observeSingleEvent(of: .value) { (snapShot) in
            self.pinVisitedUsers.removeAll()
            let dict = snapShot.value as? NSDictionary
            let values = dict?.allValues
            if let idArr = dict?.allKeys{
                self.count = idArr.count
                if self.count == 0{
                    completion(true)
                }
                for (index,item) in idArr.enumerated(){
                    FollowVM.shared.getUserDetail(userId: item as! String, completion: { (user) in
                        self.count = self.count - 1
                        self.pinVisitedUsers.append(PinVisitedByUsers(user: user, visitedDate: values![index] as? Int ?? 0))
                        if self.count == 0{
                            completion(true)
                        }
                    })
                    
                }
            }else{
                completion(true)
                print("no followers")
            }
        }
    }
    
    
    func getPincomments(pinId : String,completion: @escaping (Bool) -> Void){
        ref.child(PinComments).child(pinId).observeSingleEvent(of: .value) { (snapShot) in
            self.pinComments.removeAll()
            let children = snapShot.children
            for child in children{
                if let snapShotDict = child as? DataSnapshot{
                    if let value = snapShotDict.value as? NSDictionary{
                        let text = value[FireBaseConstant.kText] as? String ?? ""
                        let timeStamp = value[FireBaseConstant.kTimestamp] as? Int ?? 0
                        var user : UserDetail!
                        if let userDict = value[FireBaseConstant.kUser] as? NSDictionary{
                            user =  UserVM.shared.parasUserDetail(user: userDict)
                        }
                        self.pinComments.append(PinComment(text: text, timestamp: timeStamp, user: user))
                    }
                }
            }
            completion(true)
        }
    }
    
    func addComment(pinId: String,text : String, pin: PinsSnapShot){
        let dict = [FireBaseConstant.kText : text,
                    FireBaseConstant.kTimestamp: [".sv": "timestamp"],
                    FireBaseConstant.kUser: MyUserDetail] as [String : Any]
        ref.child(PinComments).child(pinId).childByAutoId().setValue(dict)
        
        let pinActivityDict = [FireBaseConstant.kDate : [".sv": "timestamp"],
                               FireBaseConstant.kType : 1,
                               FireBaseConstant.kUser: MyUserDetail] as [String : Any]
        ref.child(PinActivity).child(pinId).childByAutoId().setValue(pinActivityDict)
        
        
        let userActivityDict = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                FireBaseConstant.kPin : [FireBaseConstant.kKey: pinId,
                                                         FireBaseConstant.kTitle: pin.title,
                                                         FireBaseConstant.kType: pin.type],
                                FireBaseConstant.kType : 1] as [String : Any]
        ref.child(UserActivity).child(DataManager.userId!).childByAutoId().setValue(userActivityDict)
        let updateNotification = [FireBaseConstant.kDate: [".sv": "timestamp"],
                                  FireBaseConstant.kType : 2,
                                  FireBaseConstant.kTitle : DataManager.name ?? DataManager.email!,
                                  FireBaseConstant.kPin : [FireBaseConstant.kKey : pin.key,
                                                           FireBaseConstant.kTitle: pin.title,
                                                           FireBaseConstant.kType : pin.type],
                                  FireBaseConstant.kUser : MyUserDetail] as [String : Any]
        self.ref.child(UserNotifications).child(DataManager.userId!).childByAutoId().setValue(updateNotification)
        
        self.ref.child(UserFcmIds).child(pin.user.uid).observe(.value) { (snap) in
            if let valuedict = snap.value as? NSDictionary{
                let fcmIds = valuedict.allKeys
                for key in fcmIds{
                    if key is String{
                        UpdatePinVM.shared.sendNotification(senderId: key as! String, title: pin.title, body: "\(pin.user.name) is commented on your pin")
                    }
                }
            }
        }
        
    }
    
    
    func getUserActivity(userId : String,completion: @escaping (Bool) -> Void){
        ref.child(UserActivity).child(userId).observeSingleEvent(of: .value) { (snapShot) in
            self.userFeeds.removeAll()
            let children = snapShot.children
            for child in children{
                if let snapShotDict = child as? DataSnapshot{
                    if let value = snapShotDict.value as? NSDictionary{
                        let date = value[FireBaseConstant.kDate] as? Int ?? 0
                        let type = value[FireBaseConstant.kType] as? Int ?? 0
                        var pin = Pin()
                        if let pinDict = value[FireBaseConstant.kPin] as? NSDictionary{
                           let key = pinDict[FireBaseConstant.kKey] as? String ?? ""
                            let title = pinDict[FireBaseConstant.kTitle] as? String ?? ""
                            let type = pinDict[FireBaseConstant.kType] as? String ?? ""
                            pin = Pin(key: key, title: title, type: type)
                         }
                        self.userFeeds.append(UserFeed(date: date, type: type, pin: pin))
                    }
                }
            }
            completion(true)
        }
    }
    
}
