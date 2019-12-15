//
//  DataModel.swift
//  BookBeak
//
//  Created by Maninder Singh on 18/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import Foundation
import CoreLocation


var globleCurrentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
struct PinsSnapShot {
    var coordinates : Coordinates
    var description : String
    var key : String
    var media : [PinMedia]!
    var notes : String
    var ratedTimes : Int
    var rating : Int
    var title : String
    var type : String
    var user : UserDetail
    var visitedCount : Int
    var ditance : Int
    var creationTime : Int
}

struct Coordinates {
    var lat : Double
    var lon : Double
}

struct PinMedia {
    var name : String
    var thumbnailName : String
    var type: String
    var uri : String!
}


struct UserPinsDetail {
    var pin : PinsSnapShot
}

struct PinVisitedByUsers {
    var user : UserDetail!
    var visitedDate : Int!
}

struct PinComment {
    var text : String!
    var timestamp : Int!
    var user : UserDetail!
}


let MyUserDetail = [FireBaseConstant.kEmail: DataManager.email!,
                    FireBaseConstant.kName: DataManager.name ?? DataManager.email!,
                    FireBaseConstant.kNameForSearch: DataManager.name?.capitalized ?? DataManager.email!,
                    FireBaseConstant.kPhotoUrl:DataManager.UserImageURL ?? "null",
                    FireBaseConstant.kUid: DataManager.userId!,
                    FireBaseConstant.korigin : DataManager.location ?? "",
                    FireBaseConstant.ksocialUrl :DataManager.webAddress ?? ""]


struct UserDetail {
    var name : String
    var email : String
    var photoUrl : String
    var uid : String
}

struct UserFeed {
    var date : Int!
    var type : Int!
    var pin : Pin!
}

struct PinFeed {
    var date : Int!
    var type : Int!
    var user : UserDetail!
}

struct Pin {
    var key :String!
    var title : String!
    var type: String!
}

struct AppNotification {
    var key : String!
    var date : Int!
    var title : String!
    var type : Int!
    var pin : Pin!
    var user : UserDetail?
}
extension UserVM{
    
    func parasUserDetail(user : NSDictionary) -> UserDetail{
        let name = user[FireBaseConstant.kName] as! String
        let email = user[FireBaseConstant.kEmail] as! String
        let photoUrl = user[FireBaseConstant.kPhotoUrl] as? String ?? ""
        let uid = user[FireBaseConstant.kUid] as! String
        return UserDetail(name: name, email: email, photoUrl: photoUrl, uid: uid)
    }
}
