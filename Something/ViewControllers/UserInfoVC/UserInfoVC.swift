//
//  UserInfoVC.swift
//  Something
//
//  Created by Maninder Singh on 11/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import Parchment
import FAPanels

class UserInfoVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var workingView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: MSBImageView!
    
    //MARK:- Variables
//    let VCs = ["CreatedVC","CheckedInVC","FeedVC","BioVC"]
//    let VCName = ["CREADED","CHECKED IN", "FEED","BIO"]
    
    let VCs = ["CreatedVC","FeedVC","BioVC"]
    let VCName = ["CREADED", "FEED","BIO"]
    var userDetail : UserDetail?
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlImaeg = URL(string: userDetail?.photoUrl ?? ""){
            userImageView.sd_setImage(with: urlImaeg, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        userNameLabel.text = userDetail?.name ?? ""
        
        
        let pagingViewController = PagingViewController<PagingIndexItem>()
        pagingViewController.dataSource = self
        pagingViewController.select(index: 0)
        pagingViewController.textColor = UIColor.lightGray
        pagingViewController.selectedTextColor = UIColor.white
        pagingViewController.selectedBackgroundColor = defaultColor
        pagingViewController.backgroundColor = defaultColor
        pagingViewController.indicatorColor = UIColor.white
        pagingViewController.borderColor = defaultColor
        addChildViewController(pagingViewController)
        workingView.addSubview(pagingViewController.view)
        workingView.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        FollowVM.shared.searchForFollow(userId: userDetail!.uid) { (success) in
            if success{
                self.followButton.setImage(#imageLiteral(resourceName: "user-with-minus-sign"), for: .normal)
            }else{
                 self.followButton.setImage(#imageLiteral(resourceName: "user-male-black-shape-with-plus-sign"), for: .normal)
            }
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func blockuser(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure!", message: " \n you want to block this user", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                UserVM.shared.blockUser(blockedUser: self.userDetail!)
                let alert = UIAlertController(title: "", message: "Blocked Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
       
    }
    
    @IBAction func messageButton(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        VC.userNameForNavigation = userDetail?.name ?? ""
        VC.otherUserId = userDetail?.uid ?? ""
        VC.otherUserToken = userDetail?.fcmToken ?? "otherUserToken"
        let myid = UserDetail(name: DataManager.name!, email: DataManager.email!, photoUrl: DataManager.UserImageURL ?? "", uid: DataManager.userId!, fcmToken: DataManager.deviceToken!)
        let room = ChatVM.shared.createChatRoom(user1: myid, user2: userDetail!)
        VC.roomId = room.0
        VC.userImage =  userDetail?.photoUrl ?? ""
        VC.otherUserDetail = userDetail
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func followUserButton(_ sender: Any) {
        if followButton.imageView?.image == #imageLiteral(resourceName: "user-with-minus-sign"){
            FollowVM.shared.unSuscribeUser(userId: userDetail!.uid)
            followButton.setImage(#imageLiteral(resourceName: "user-male-black-shape-with-plus-sign"), for: .normal)
            let sender = PushNotificationSender()
            let somebody = userDetail!.name
            sender.sendPushNotification(to: userDetail!.fcmToken, title: "Unfollowing!", body: "\(somebody) unfollowed you!")
           
        }else{
            FollowVM.shared.suscribeUser(userId: userDetail!.uid)
            followButton.setImage(#imageLiteral(resourceName: "user-with-minus-sign"), for: .normal)
            let sender = PushNotificationSender()
            let somebody = userDetail!.name
            sender.sendPushNotification(to: userDetail!.fcmToken, title: "Following!", body: "\(somebody) followed you!")
        }
        
        
    }
    //MARK:- Custom Methods


}

//MARK:- PageViewController
extension UserInfoVC: PagingViewControllerDataSource {
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int {
        return VCs.count
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return PagingIndexItem(index: index, title: VCName[index]) as! T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        return setVC(viewControler: VCs[index])
    }
    
    func setVC(viewControler : String) -> UIViewController{
        
        if viewControler == "CreatedVC"{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "CreatedVC") as! CreatedVC
            VC.userId = (userDetail?.uid)!
            return VC
        }
        if viewControler == "CheckedInVC"{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "CheckedInVC") as! CheckedInVC
            VC.userId = (userDetail?.uid)!
            return VC
        }
        if viewControler == "FeedVC"{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC") as! FeedVC
            VC.userId = (userDetail?.uid)!
            return VC
        }
        else{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "BioVC") as! BioVC
            VC.userId = (userDetail?.uid)!
            return VC
        }
        //let VC = self.storyboard?.instantiateViewController(withIdentifier: viewControler)
    }
}
