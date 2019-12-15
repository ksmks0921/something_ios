//
//  EmailVC.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import FirebaseAuth
import TwitterKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseDatabase

class EmailVC: BaseVC {

    //MARK:- IBOutlets
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    //MARK:- Variables
    var ref : DatabaseReference!
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        emailTF.setPlaceHolderColor()
    }
    
    //MARK:- IBActions

    @IBAction func googleButton(_ sender: Any) {
        googlePlusLogin()
    }
    
    @IBAction func faceBookButton(_ sender: Any) {
        FBLogin()
    }
    
    @IBAction func twitterButton(_ sender: Any) {
        twitterLogin()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if emailTF.isEmpty{
            self.showAlert(message: "Please enter your email.")
            return
        }
        if !emailTF.isValidEmail{
            self.showAlert(message: "Please enter valid email address")
            return
        }
        self.view.endEditing(true)
        checkEmail()
    }
    
    //MARK:- Custom Methods

    func twitterLogin(){
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                let credential = TwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        self.showAlert(message: error.localizedDescription)
                        return
                    }
                    DataManager.userId = user?.uid
                    DataManager.email = user?.email
                    DataManager.name = user?.displayName ?? "No name"
                    let updateUser = [FireBaseConstant.kEmail: DataManager.email!,
                                      FireBaseConstant.kName: DataManager.name!,
                                      FireBaseConstant.kNameForSearch: DataManager.name!.uppercased(),
                                      FireBaseConstant.kPhotoUrl:"",
                                      FireBaseConstant.kUid: DataManager.userId!]
                    self.ref.child(UserNode).child(DataManager.userId!).setValue(updateUser)
                    self.ref.child(UserFcmIds).child(DataManager.userId!).child(DataManager.deviceToken!).setValue(true)
                    DataManager.isLogin = true
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! PageVC
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            } else {
                self.showAlert(message: error?.localizedDescription)
            }
        })
    }
    
    func FBLogin(){
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        fbManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (loginResult, error) in
            if error != nil{
                self.showAlert(message: error?.localizedDescription)
            }
            else{
                if !(loginResult!.isCancelled){
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signIn(with: credential) { (user, error) in
                        if let error = error {
                            self.showAlert(message: error.localizedDescription)
                            return
                        }
                        DataManager.userId = user?.uid
                        DataManager.email = user?.email
                        DataManager.name = user?.displayName ?? "No name"
                        if DataManager.email == nil{
                            self.showAlert(message: "We are unable to fetch your email address. Please singup.")
                            return
                        }
                        let updateUser = [FireBaseConstant.kEmail: DataManager.email!,
                                          FireBaseConstant.kName: DataManager.name!,
                                          FireBaseConstant.kNameForSearch: DataManager.name!.uppercased(),
                                          FireBaseConstant.kPhotoUrl:"",
                                          FireBaseConstant.kUid: DataManager.userId!]
                        self.ref.child(UserNode).child(DataManager.userId!).setValue(updateUser)
                        self.ref.child(UserFcmIds).child(DataManager.userId!).child(DataManager.deviceToken!).setValue(true)
                         DataManager.isLogin = true
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! PageVC
                        self.navigationController?.pushViewController(VC, animated: true)
                    }
                }
            }
        }
    }
    
    func googlePlusLogin(){
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
}


//MARK:- FireBase Methods
extension EmailVC{
    
    func checkEmail(){
        Indicator.sharedInstance.showIndicator()
        Auth.auth().fetchProviders(forEmail: emailTF.text!) { (emails, error) in
            Indicator.sharedInstance.hideIndicator()
            if error == nil{
                if emails == nil {
                    // signup
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                    VC.email = self.emailTF.text
                    self.navigationController?.pushViewController(VC, animated: true)
                }else{
                    // login
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
                    VC.email = self.emailTF.text
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            }else{
                self.showAlert(message: error?.localizedDescription)
            }
        }
    }
}


extension EmailVC: GIDSignInUIDelegate,GIDSignInDelegate{
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil{
            self.showAlert(message: error?.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            DataManager.userId = user?.uid
            DataManager.email = user?.email
            DataManager.name = user?.displayName ?? "No name"
            let updateUser = [FireBaseConstant.kEmail: DataManager.email!,
                              FireBaseConstant.kName: DataManager.name!,
                              FireBaseConstant.kNameForSearch: DataManager.name!.uppercased(),
                              FireBaseConstant.kPhotoUrl:"",
                              FireBaseConstant.kUid: DataManager.userId!]
            self.ref.child(UserNode).child(DataManager.userId!).setValue(updateUser)
            self.ref.child(UserFcmIds).child(DataManager.userId!).child(DataManager.deviceToken!).setValue(true)
            DataManager.isLogin = true
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! PageVC
            self.navigationController?.pushViewController(VC, animated: true)
        }

    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}
