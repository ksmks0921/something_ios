//
//  DataManager.swift
//  FriendsApp
//
//  Created by Maninder Singh on 21/10/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//

import Foundation
class DataManager{
    
    static var userId:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kUserId)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kUserId)
        }
    }
    
    static var selectedMap:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "kSelectedMap")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "kSelectedMap")
        }
    }
    

    
    static var name:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kName)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kName)
        }
    }
    
    static var UserImageURL:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kPhotoUrl)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kPhotoUrl)
        }
    }
    
    static var location:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kLocation)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kLocation)
        }
    }
    
    static var webAddress:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kWebAddress)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kWebAddress)
        }
    }
    
    
    
    static var email:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kUserEmail)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kUserEmail)
        }
    }
    
//    static var userImage:String? {
//        set {
//            UserDefaults.standard.setValue(newValue, forKey: kUserImage)
//            UserDefaults.standard.synchronize()
//        }
//        get {
//            return UserDefaults.standard.string(forKey: kUserImage)
//        }
//    }
    
    static var deviceToken:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kDeviceToken)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kDeviceToken)
        }
    }
    
    
    static var isLogin: Bool?{
        set{
            UserDefaults.standard.setValue(newValue, forKey: kLoginStatus)
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: kLoginStatus)
        }
    }
    
    
    
}

