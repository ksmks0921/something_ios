//
//  AppDelegate.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FAPanels
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics
import TwitterKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?

    var locationManager = CLLocationManager()
    var userCurrentLocation : CLLocationCoordinate2D?
    var userStartLocation : CLLocationCoordinate2D?
    var isLocationUpdatedFirstTime = false
    var ref : DatabaseReference!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        Fabric.with([Crashlytics.self])
        
        FirebaseApp.configure()
        GMSServices.provideAPIKey(GoogleMapKey)
        GMSPlacesClient.provideAPIKey(GoogleMapKey)
        TWTRTwitter.sharedInstance().start(withConsumerKey:"5gS4rid3hKOwQzW7fYqw3H55K", consumerSecret:"2HfgDiW2HC3yfsi8G5i88c0DP7xslDFMuev3euhzfptZ1LqmgU")
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        //Notifications
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        ref = Database.database().reference()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            //FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
//        application.registerForRemoteNotifications()
        self.getNotificationSettings()
        setRootVC()
        return true
    }
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       // InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        //InstanceID.instanceID().token()
        print("Registration succeeded! Token: ", token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        setRootVC()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "fb946413918842139"{
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as! String!, annotation: options[.annotation])

        }
        if url.scheme == ""{
            return GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        else{
            return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        }
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        
        // Print full message.
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        // Print full message.
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground\(notification.request.content.userInfo)")
        
        if let dict = notification.request.content.userInfo["aps"] as? NSDictionary{
            if let d = dict["alert"] as? NSDictionary{
                let body : String = d["body"] as? String ?? ""
                let title : String = d["title"] as? String ?? ""
                self.showAlertAppDelegate(title: title,message: body,buttonTitle:"ok",window:self.window!)
            }
            
        }else{
            self.showAlertAppDelegate(title: notification.request.content.title,message: notification.request.content.body ,buttonTitle:"ok",window:self.window!)
        }
        
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        //setRootVC(isNotficationArrived: true)
        print("Handle push from background or closed\(response.notification.request.content.userInfo)")
    }
    
    func showAlertAppDelegate(title: String,message : String,buttonTitle: String,window: UIWindow){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        window.rootViewController?.present(alert, animated: false, completion: nil)
    }


}

extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let token = Messaging.messaging().fcmToken
        
        print("________FCM token: \(token ?? "")")
        DataManager.deviceToken = token
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        
    }
    
    
}


extension AppDelegate {
    
    func setRootVC(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            if DataManager.isLogin!{
            let NAVC = mainStoryboard.instantiateViewController(withIdentifier: "loginNAVC") as! UINavigationController
            let VC = mainStoryboard.instantiateViewController(withIdentifier: "PannelVC") as! FAPanelController
            let leftMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
            let rightMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let centerNavVC = UINavigationController(rootViewController: rightMenuVC)
            centerNavVC.isNavigationBarHidden = true
            VC.configs.shadowColor = UIColor.black.cgColor
            VC.configs.shadowOffset = CGSize(width: 10.0, height: 200.0)
            VC.configs.shadowOppacity = 0.5
            VC.configs.leftPanelGapPercentage = 0.75
            _ = VC.center(centerNavVC).left(leftMenuVC)
            NAVC.setViewControllers([VC], animated: false)
            window?.rootViewController = NAVC
//        }else{
//            let leftMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "NAVC")
//            self.window?.rootViewController = leftMenuVC
//        }
    }
    
}


extension AppDelegate : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            locationManager.stopUpdatingLocation()
            let alert = UIAlertController(title: "Alert", message: "Please allow location services from setting.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.default, handler: nil))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        else if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }
        else if authorizationStatus == .authorizedAlways{
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location =  locations.first else {
            return
        }
        globleCurrentLocation = location.coordinate
        if !isLocationUpdatedFirstTime{
            isLocationUpdatedFirstTime = true
            NotificationCenter.default.post(Notification.init(name: Notification.Name.init("FirstUpdate")))
        }
        guard let _ =  DataManager.userId else {
            return
        }
        let geoRef = GeoFire.init(firebaseRef: ref.child(PinsGeofire))
        let geoQuery = geoRef.query(at: location, withRadius: 0.1)
        geoQuery.observe(.keyEntered) { (key, location) in
            UpdatePinVM.shared.isPinVisited(pinId: key, completion: { (success) in
                if !success{
                    UpdatePinVM.shared.addToMissedPin(pinId: key)
                }
            })
        }
        
        

    }
    
    
}
