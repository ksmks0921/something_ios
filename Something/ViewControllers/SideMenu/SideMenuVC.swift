//
//  SideMenuVC.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import  FirebaseDatabase
import SDWebImage

class SideMenuVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    //MARK:- Variables
    var ref: DatabaseReference!

    let itemsArr = ["Your Profile", "Your Places", "Users", "Messages","Block List", "Logout"]
    let itemsArr_in = ["Log In"]
    let ImagesArr = [#imageLiteral(resourceName: "person_black.png"),#imageLiteral(resourceName: "sideMarker"),#imageLiteral(resourceName: "SideUser"),#imageLiteral(resourceName: "sideMessage"),#imageLiteral(resourceName: "sideMessage"),#imageLiteral(resourceName: "sideLogouit")]
    let ImagesArr_in = [#imageLiteral(resourceName: "sideLogouit")]
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        if DataManager.name == nil{
            getUserDetail()
        }else{
            self.userName.text = DataManager.name ?? "No Name"
            self.userEmail.text = DataManager.email ?? ""
        }
        
    }
    
    //MARK:- IBActions
    
    @IBAction func editProfileButton(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileDetailVC") as! MyProfileDetailVC
        panel?.closeLeft()
        self.navigationController?.pushViewController(VC, animated: true)
    }
    func showDialog(){
        let alert = UIAlertController(title: "Alert", message: "You have to create an account to do this action!", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: {action in
            
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "EmailVC") as! EmailVC
            self.navigationController?.pushViewController(VC, animated: true)
            //                self.present(VC, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    //MARK:- Custom Methods

}

extension SideMenuVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if DataManager.isLogin!{
            return itemsArr.count
        }
        else {
            return itemsArr_in.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell") as! SideMenuCell
        
        if DataManager.isLogin!{
            
            cell.itemName.text = itemsArr[indexPath.row]
            cell.itemImage.image = ImagesArr[indexPath.row]
            cell.selectionStyle = .none
            return cell
                
        }
        else {
            
            cell.itemName.text = itemsArr_in[indexPath.row]
            cell.itemImage.image = ImagesArr_in[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
        
       
        
       
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if DataManager.isLogin!{
            if indexPath.row == 0{
                
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                self.navigationController?.pushViewController(VC, animated: true)
                
                
                
                //            let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                //            _ = panel?.center(VC)
            }
            if indexPath.row == 1{
                
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileDetailVC") as! MyProfileDetailVC
                self.navigationController?.pushViewController(VC, animated: true)
                
                
                //            let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileDetailVC") as! MyProfileDetailVC
                //            _ = panel?.center(VC)
            }
            if indexPath.row == 2{
                
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "UsersVC") as! UsersVC
                _ = panel?.center(VC)
                
            }
            
            if indexPath.row == 3{
                
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
                _ = panel?.center(VC)
                
            }
            if indexPath.row == 4{
                
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "BlockListVC") as! BlockListVC
                _ = panel?.center(VC)
                
            }
            if indexPath.row == 5{
                
                DataManager.isLogin = false
                DataManager.name = nil
                DataManager.userId = nil
                DataManager.UserImageURL = nil
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let leftMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "NAVC")
                let app = UIApplication.shared.delegate as! AppDelegate
                app.window?.rootViewController = leftMenuVC
                
                
                
            }
        }
        else {
            if indexPath.row == 0{
                
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "EmailVC") as! EmailVC
                self.navigationController?.pushViewController(VC, animated: true)
                
                
                
                //            let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                //            _ = panel?.center(VC)
            }
        }
        
    }
}

//MARK:- Firebase methods
extension SideMenuVC{
    func getUserDetail(){
        if DataManager.isLogin!{
        ref.child(UserNode + "/\(DataManager.userId!)").observe(.value) { (userSanpShot) in
            if let userData = userSanpShot.value as? NSDictionary{
                DataManager.email = userData[FireBaseConstant.kEmail] as? String
                DataManager.name = userData[FireBaseConstant.kName] as? String
                DataManager.UserImageURL = userData[FireBaseConstant.kPhotoUrl] as? String
                DataManager.location = userData[FireBaseConstant.korigin] as? String
                DataManager.webAddress = userData[FireBaseConstant.ksocialUrl] as? String
                self.userName.text = DataManager.name ?? "No Name"
                self.userEmail.text = DataManager.email ?? "No Email"
                if let imageurl = DataManager.UserImageURL{
                    if let url = URL(string: imageurl){
                        self.userImage.sd_setImage(with: url, completed: nil)
                    }
                }
            }
        }
      }
    }
}
