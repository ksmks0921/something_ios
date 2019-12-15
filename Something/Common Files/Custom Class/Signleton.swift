//
//  Signleton.swift
//  TakeAJob
//
//  Created by Maninder Singh on 14/11/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit



/*
 1 - locations disabled

 
 
 */




protocol locationsDelegate {
    func locationError (errorNumber : Int ,ErrorDiscription: String)
    func updatedLocation(userCurrentLocation : CLLocationCoordinate2D ,userStartLocation :  CLLocationCoordinate2D)
}

class Getlocation : NSObject{
    
    
    public static let shareInstance = Getlocation()
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var userCurrentLocation : CLLocationCoordinate2D?
    fileprivate var userStartLocation : CLLocationCoordinate2D?
    fileprivate var isLocationUpdatedFirstTime = false
    var delagate : locationsDelegate?


    private override init () {
        super.init()
   
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func openSetting(){
        if #available(iOS 10.0, *){
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        
    }
    
    func updateLocation(){
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocations(){
        locationManager.stopUpdatingLocation()
    }
}

//MARK:- Location manager delegates
extension Getlocation : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            locationManager.stopUpdatingLocation()
            delagate?.locationError(errorNumber: 1, ErrorDiscription: "Location Services are disabled.")
        }
        else if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }
        else if authorizationStatus == .authorizedAlways{
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userStartLocation = (locations.last?.coordinate)!
        //if location is off and user again start location it will update to cuurent location only for one time
        if !isLocationUpdatedFirstTime{
            isLocationUpdatedFirstTime = true
            userCurrentLocation = (manager.location?.coordinate)!
        }
        delagate?.updatedLocation(userCurrentLocation: userCurrentLocation!, userStartLocation: userStartLocation!)
    }
    
}

