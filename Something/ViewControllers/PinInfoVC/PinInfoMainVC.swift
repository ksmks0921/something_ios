//
//  PinInfoMainVC.swift
//  Something
//
//  Created by Maninder Singh on 15/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import Parchment
import CoreLocation

struct IconItem: PagingItem, Hashable, Comparable {
    
    let icon: String
    let index: Int
    let image: UIImage?
    
    init(icon: String, index: Int) {
        self.icon = icon
        self.index = index
        self.image = UIImage(named: icon)
    }
    
    var hashValue: Int {
        return icon.hashValue
    }
    
    static func <(lhs: IconItem, rhs: IconItem) -> Bool {
        return lhs.index < rhs.index
    }
    
    static func ==(lhs: IconItem, rhs: IconItem) -> Bool {
        return (
            lhs.index == rhs.index &&
                lhs.icon == rhs.icon &&
                lhs.image == rhs.image
        )
    }
}

class PinInfoMainVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var workingView: UIView!
    @IBOutlet weak var toplabel: UILabel!
    @IBOutlet weak var pinImage: UIImageView!
    
    //MARK:- Variables
    var pinDetail : PinsSnapShot!
    var isMissedPin = false
    var isVisitedPin = false
//    let icons1 = ["information","location_right_icon-1","chat","users-2"]
//    let icons = ["PinLocationInfo","PinCheckedInInfo","PinsComment","PinFeeds"]
    let icons1 = ["information","chat"]
    let icons = ["PinLocationInfo","PinsComment"]
    var currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        var uri = ""
        if let mediaItem  = pinDetail.media{
            for data in mediaItem{
                uri = data.uri
            }
        }
        if let imageUrl = URL(string: uri){
            pinImage.sd_setImage(with: imageUrl, completed: nil)
        }
        toplabel.text = pinDetail.title
        
        
        let pagingViewController = PagingViewController<IconItem>()
        pagingViewController.menuItemSource = .class(type: IconPagingCell.self)
        pagingViewController.menuHorizontalAlignment = .center
        pagingViewController.menuItemSize = .fixed(width: 60, height: 60)
        pagingViewController.textColor = UIColor(red: 0.51, green: 0.54, blue: 0.56, alpha: 1)
        pagingViewController.selectedTextColor = UIColor(red: 0.14, green: 0.77, blue: 0.85, alpha: 1)
        pagingViewController.indicatorColor = UIColor(red: 0.14, green: 0.77, blue: 0.85, alpha: 1)
        pagingViewController.dataSource = self
         pagingViewController.select(pagingItem: IconItem(icon: icons1[0], index: 0))
        
        // Add the paging view controller as a child view controller
        // and contrain it to all edges.
        addChildViewController(pagingViewController)
        workingView.addSubview(pagingViewController.view)
        workingView.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
    }
    
    //MARK:- IBActions
    
    @IBAction func reportPost(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure!", message: " \n you want to report this pin", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                UserVM.shared.reportPost( Pinid: self.pinDetail)
                let alert = UIAlertController(title: "", message: "Reported Successfully.", preferredStyle: UIAlertControllerStyle.alert)
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
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       // self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Custom Methods

}

extension PinInfoMainVC: PagingViewControllerDataSource {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
         return setVC(viewControler: icons[index])
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return IconItem(icon: icons1[index], index: index) as! T
    }
    
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return icons.count
    }
    
    
    func setVC(viewControler : String) -> UIViewController{
        
        if viewControler == "PinLocationInfo"{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PinLocationInfo") as! PinLocationInfo
            VC.pinDetail = pinDetail
            VC.isMissedPin = self.isMissedPin
            VC.isVisitedPin = self.isVisitedPin
            VC.currentLocation = currentLocation
            return VC
        }
//        if viewControler == "PinCheckedInInfo"{
//            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PinCheckedInInfo") as! PinCheckedInInfo
//            VC.pinDetail = pinDetail
//            VC.isMissedPin = self.isMissedPin
//            VC.isVisitedPin = self.isVisitedPin
//            return VC
//        }
        else {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PinsComment") as! PinsComment
            VC.isMissedPin = self.isMissedPin
            VC.isVisitedPin = self.isVisitedPin
            VC.pinDetail = pinDetail
            return VC
        }
//        else{
//            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PinFeeds") as! PinFeeds
//            VC.pinDetail = pinDetail
//            return VC
//        }
    }
}
