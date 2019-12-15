//
//  UsersVC.swift
//  Something
//
//  Created by Maninder Singh on 02/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import Parchment
import FAPanels

class UsersVC: BaseVC {
    //MARK:- IBOutlets
    
    @IBOutlet weak var workingView: UIView!
    
    //MARK:- Variables
    let VCs = ["FollowingVC","FollowersVC"]
    let VCName = ["Following","Followers"]
    let pagingViewController = PagingViewController<PagingIndexItem>()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
   
    //MARK:- IBActions
    
    @IBAction func menuButton(_ sender: Any) {
         panel?.openLeft(animated: true)
    }
    
    @IBAction func sreachbutton(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SearchUserVC") as! SearchUserVC
        VC.isFromMessageVC = false
        self.navigationController?.pushViewController(VC, animated: true)
    }
    //MARK:- Custom Methods

   

}


//MARK:- PageViewController
extension UsersVC: PagingViewControllerDataSource {
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
        let VC = self.storyboard?.instantiateViewController(withIdentifier: viewControler)
        return VC!
    }
}
