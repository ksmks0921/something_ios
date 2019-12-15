//
//  APIKey.swift
//  FriendsApp
//
//  Created by Maninder Singh on 21/10/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//

import Foundation
class FireBaseConstant{
    
    enum MarkerType : String{
        case EVENT
        case HISTORICAL
        case VIEWPOINT
        case OFFER
        case ATTRACTION
        case EXPERIENCE
    }
    
    enum ActivityType : String{
        case PIN_CREATED
        case PIN_COMMENTED
        case PIN_VISITED
        case PIN_RATED
        case SUBSCRIBED
        case UNSUBSCRIBED
        case PIN_EDITED
        case PIN_DELETED
    }
    //FireBase Node
    
    
    //Common
    static let kMessage = "message"
    static let kSuccess = "success"
    
    //User
    
    static let kEmail = "email"
    static let kNameForSearch = "nameForSearch"
    static let kPhotoUrl = "photoUrl"
    static let kName = "name"
    static let kUid = "uid"
    static let korigin = "origin"
    static let ksocialUrl = "socialUrl"
    
    //Pin Detail
    static let kDate = "date"
    static let kType = "type"
    static let kPin = "pin"
    static let kTitle = "title"
    static let kKey = "key"
    static let kUser = "user"
    static let kCoordinates = "coordinates"
    static let kCreationTime = "creationTime"
    static let kDescription = "description"
    static let kNotes = "notes"
    static let kRatedTimes = "ratedTimes"
    static let kRating = "rating"
    static let kVisitedCount = "visitedCount"
    static let kLat = "lat"
    static let kLong = "lon"
    
    static let kMedia = "media"
    static let kThumbnailName = "thumbnailName"
    static let kUri = "uri"
    static let kUser1 = "user1"
    static let kUser2 = "user2"
    static let klastMsg = "lastMsg"
    static let kUserId = "userId"
    static let kText = "text"
    static let kTimestamp = "timestamp"
    
    static let kBlockBy = "blockby"
    static let kBlockedTo = "blockto"

}

