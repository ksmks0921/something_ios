//
//  PasswordVC.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FAPanels
import FirebaseDatabase

class PasswordVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var showHideButton: UIButton!
    @IBOutlet weak var checkbutton: UIButton!
    
    //MARK:- Variables
    var email : String!
    var ref: DatabaseReference!
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTF.setPlaceHolderColor()
        passwordTF.setPlaceHolderColor()
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if email != nil{
            emailTF.text = email
        }
    }
    
    //MARK:- IBActions
    @IBAction func forgotPasswordButtonAction(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil{
                self.showAlert(message: "Reset password has been sent to your email.")
            }else{
                self.showAlert(message: error?.localizedDescription)
            }
        }
    }
    @IBAction func termsButtonAction(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://thesomethingapp.weebly.com/term-of-use.html")!)
    }
    
    @IBAction func checkBoxButtonAction(_ sender: Any) {
        if checkbutton.currentImage == #imageLiteral(resourceName: "square"){
            checkbutton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        }else{
            checkbutton.setImage(#imageLiteral(resourceName: "square"), for: .normal)
        }
    }
    
    @IBAction func showHideButton(_ sender: Any) {
         passwordTF.isSecureTextEntry = !passwordTF.isSecureTextEntry
        if passwordTF.isSecureTextEntry{
            showHideButton.setImage(#imageLiteral(resourceName: "hide"), for: .normal)
        }else{
             showHideButton.setImage(#imageLiteral(resourceName: "show"), for: .normal)
        }
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        if emailTF.isEmpty{
            self.showAlert(message: "Please enter your email.")
            return
        }
        if !emailTF.isValidEmail{
            self.showAlert(message: "Please enter valid email address.")
            return
        }
        if passwordTF.isEmpty{
            self.showAlert(message: "Please enter your password.")
            return
        }
        if checkbutton.currentImage == #imageLiteral(resourceName: "square"){
            self.showAlert(message: "Please agree to terms and condtions.")
            return
        }
        self.view.endEditing(true)
        login()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Custom Methods

}

//MARK:- FireBase Methods
extension PasswordVC{
    
    func login(){
        Indicator.sharedInstance.showIndicator()
        UserVM.shared.login(email: emailTF.text!, password: passwordTF.text!) { (success, message, error) in
            if error == nil{
                if success{
                    
                    DataManager.isLogin = true
//                    DataManager.email = self.emailTF.text!
                    let VC_again = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    self.navigationController?.pushViewController(VC_again, animated: true)
                    
                   
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let app = UIApplication.shared.delegate as! AppDelegate

                    let NAVC = mainStoryboard.instantiateViewController(withIdentifier: "loginNAVC") as! UINavigationController
                    let VC = mainStoryboard.instantiateViewController(withIdentifier: "PannelVC") as! FAPanelController
                    let leftMenuVC_again = mainStoryboard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                    let rightMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    let centerNavVC = UINavigationController(rootViewController: rightMenuVC)
                    centerNavVC.isNavigationBarHidden = true
                    VC.configs.shadowColor = UIColor.black.cgColor
                    VC.configs.shadowOffset = CGSize(width: 10.0, height: 200.0)
                    VC.configs.shadowOppacity = 0.5
                    VC.configs.leftPanelGapPercentage = 0.75
                    _ = VC.center(centerNavVC).left(leftMenuVC_again)
                    NAVC.setViewControllers([VC], animated: false)
                    app.window?.rootViewController = NAVC
                    
                    
                    
                }else{
                    self.showAlert(message: message)
                }
            }else{
                self.showAlert(message: error?.localizedDescription)
            }
        }
    }
    
    
    
}
