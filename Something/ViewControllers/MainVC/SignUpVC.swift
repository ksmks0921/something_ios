//
//  SignUpVC.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FAPanels

class SignUpVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var checkbutton: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var showHideButton: UIButton!
    
    //MARK:- Variables
    var email : String!
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTF.setPlaceHolderColor()
        nameTF.setPlaceHolderColor()
        passwordTF.setPlaceHolderColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if email != nil{
            emailTF.text = email
        }
    }
    
    //MARK:- IBActions
    @IBAction func showHideButton(_ sender: Any) {
        passwordTF.isSecureTextEntry = !passwordTF.isSecureTextEntry
        if passwordTF.isSecureTextEntry{
            showHideButton.setImage(#imageLiteral(resourceName: "hide"), for: .normal)
        }else{
            showHideButton.setImage(#imageLiteral(resourceName: "show"), for: .normal)
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signupButtonAction(_ sender: Any) {
        if emailTF.isEmpty{
            self.showAlert(message: "Please enter your email.")
            return
        }
        if !emailTF.isValidEmail{
            self.showAlert(message: "Please enter valid email address.")
            return
        }
        if nameTF.isEmpty{
            self.showAlert(message: "Please enter your name.")
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
        signup()
    }
    
    @IBAction func checkBoxButton(_ sender: Any) {
        if checkbutton.currentImage == #imageLiteral(resourceName: "square"){
            checkbutton.setImage(#imageLiteral(resourceName: "black-check-box-with-white-check"), for: .normal)
        }else{
            checkbutton.setImage(#imageLiteral(resourceName: "square"), for: .normal)
        }
    }
    
    @IBAction func termsButton(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://thesomethingapp.weebly.com/term-of-use.html")!)
    }
    //MARK:- Custom Methods


}

//MARK:- Firebase Methods
extension SignUpVC{
    
    func signup(){
        Indicator.sharedInstance.showIndicator()
        UserVM.shared.singUp(email: emailTF.text!, password: passwordTF.text!, name: nameTF.text!) { (success, message, error) in
            Indicator.sharedInstance.hideIndicator()
            if error == nil{
                if success{
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! PageVC
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
