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
            checkbutton.setImage(#imageLiteral(resourceName: "black-check-box-with-white-check"), for: .normal)
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
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    self.navigationController?.pushViewController(VC, animated: true)
                }else{
                    self.showAlert(message: message)
                }
            }else{
                self.showAlert(message: error?.localizedDescription)
            }
        }
    }
    
    
    
}
