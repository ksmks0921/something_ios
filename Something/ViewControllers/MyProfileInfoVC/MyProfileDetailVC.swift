//
//  MyProfileDetailVC.swift
//  Something
//
//  Created by Maninder Singh on 14/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import Parchment

class MyProfileDetailVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var navigationImage: MSBImageView!
    @IBOutlet weak var navigationName: UILabel!
    @IBOutlet weak var workingView: UIView!
    
    //MARK:- Variables
    let VCs = ["CreatedVC","PassedVC","CheckedInVC","WishlistVC","FeedVC"]
    let VCName = ["CREADED","PASSED","CHECKED IN","WISHLIST", "FEED"]
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlImage = URL(string: DataManager.UserImageURL ?? ""){
            navigationImage.sd_setImage(with: urlImage, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        navigationName.text = DataManager.name ?? ""
        
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
    }
    
    //MARK:- IBActions
    
    @IBAction func editButton(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Custom Methods

}

//MARK:- PageViewController
extension MyProfileDetailVC: PagingViewControllerDataSource {
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
            VC.userId = DataManager.userId!
            return VC
        }
        if viewControler == "PassedVC"{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PassedVC") as! PassedVC
            VC.userId = DataManager.userId!
            return VC
        }
        
        if viewControler == "CheckedInVC"{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "CheckedInVC") as! CheckedInVC
            VC.userId = DataManager.userId!
            return VC
        }
        if viewControler == "WishlistVC"{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "WishlistVC") as! WishlistVC
            VC.userId = DataManager.userId!
            return VC
        }
       else{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC") as! FeedVC
            VC.userId = DataManager.userId!
            return VC
        }
       
//        let VC = self.storyboard?.instantiateViewController(withIdentifier: viewControler)
//
//        return VC!
    }
}
