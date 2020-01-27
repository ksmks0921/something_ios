//
//  PinLocationInfo.swift
//  Something
//
//  Created by Maninder Singh on 15/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import HCSStarRatingView
import CoreLocation

class PinLocationInfo: BaseVC {

    //MARK:- IBOutlets
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var giveRatingView: HCSStarRatingView!
    @IBOutlet weak var pinRating: HCSStarRatingView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pinratingCount: UILabel!
    @IBOutlet weak var pinTypeAndCheckInCount: UILabel!
    @IBOutlet weak var pinDescription: UILabel!
    @IBOutlet weak var noteForPin: UILabel!
    @IBOutlet weak var videoLink: UILabel!
    @IBOutlet weak var createdByImageView: MSBImageView!
    @IBOutlet weak var createdByName: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var descriptionContentView: UIView!
    @IBOutlet weak var noteContentView: UIView!
    @IBOutlet weak var ratingContentView: UIView!
//    @IBOutlet weak var videoLinkContentView: UILabel!
    @IBOutlet weak var videoLinkContentView: UIView!
    
    //MARK:- Variables
    var pinDetail : PinsSnapShot!
    var currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var isMissedPin = false
    var isVisitedPin = false

    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        pinRating.value = CGFloat(pinDetail.rating)
        pinRating.isEnabled = true
    }
    
    //MARK:- IBActions
    @IBAction func shareButton(_ sender: Any) {
        let firstActivityItem = "something://"
        let activityViewController = UIActivityViewController(
            activityItems: [firstActivityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func navigationButton(_ sender: Any) {
        //open google maps if availbale
        let coordiantes = pinDetail.coordinates
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                "https://www.google.com/maps/dir/?api=1&destination=\(coordiantes.lat),\(coordiantes.lon)")!)
        }
            //open apple maps
        else{
            let url = "http://maps.apple.com/?saddr=\(currentLocation.latitude),\(currentLocation.longitude)&daddr=\(coordiantes.lat),\(coordiantes.lon)"
            UIApplication.shared.openURL(URL(string:url)!)
        }
    }
    
    @IBAction func mapButton(_ sender: Any) {
        
    }
    
    @IBAction func ratingAction(_ sender: Any) {
        if DataManager.isLogin! {
            let rating = giveRatingView.value
            
            UpdatePinVM.shared.giveRating(pin: pinDetail, rating: rating)
        }
        
        else {
            let alert = UIAlertController(title: "Alert", message: "You have to log in to do this action!", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            
            alert.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.cancel, handler: {action in
                
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "EmailVC") as! EmailVC
                self.navigationController?.pushViewController(VC, animated: true)
                //                self.present(VC, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    @IBAction func wishList(_ sender: Any) {
        let pinId = pinDetail.key
        if wishListButton.imageView?.image == #imageLiteral(resourceName: "Smallwishlist (1)"){
            CreatePinVM.shared.AddwishList(pinId: pinId)
            wishListButton.setImage(#imageLiteral(resourceName: "Smallwishlist"), for: .normal)
        }else{
            CreatePinVM.shared.removeFromWishList(pinId: pinId)
             wishListButton.setImage(#imageLiteral(resourceName: "Smallwishlist (1)"), for: .normal)
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "EditPinVC") as! EditPinVC
        VC.pinDetail = pinDetail
        self.present(VC , animated: true, completion: nil)
    }
    
    @IBAction func checkInButton(_ sender: Any) {
//        if checkInButton.imageView?.image != #imageLiteral(resourceName: "location_Green"){
//            UpdatePinVM.shared.updatePinVisited(pin: pinDetail)
//            checkInButton.setImage(#imageLiteral(resourceName: "location_Green"), for: .normal)
//        }
    }
    
    //MARK:- Custom Methods

    func setUI(){

        
        CreatePinVM.shared.searchForFav(pinId: pinDetail.key) { (success) in
            if success{
//                self.wishListButton.setImage(#imageLiteral(resourceName: "Smallwishlist"), for: .normal)
            }else{
//                self.wishListButton.setImage(#imageLiteral(resourceName: "Smallwishlist (1)"), for: .normal)
            }
        }
        
        if DataManager.isLogin! {
            if pinDetail.user.uid == DataManager.userId!{
                editButton.isHidden = false
                //            wishListButton.isHidden = true
            }else{
                editButton.isHidden = true
                //            wishListButton.isHidden = false
                //            UpdatePinVM.shared.isMissedPin(pinId: pinDetail.key) { (success) in
                //                self.isMissedPin = success
                //                if success{
                //                    self.checkInButton.isHidden = false
                //                }else{
                //                    self.checkInButton.isHidden = true
                //                }
                //            }
                
            }
        }
        else {
             editButton.isHidden = true
        }
        
        
        
        UpdatePinVM.shared.isPinVisited(pinId: pinDetail.key) { (success) in
            self.isVisitedPin = success
            if success{
//                self.checkInButton.setImage(#imageLiteral(resourceName: "location_Green"), for: .normal)
            }else{
//                self.checkInButton.setImage(#imageLiteral(resourceName: "location_right_icon-1"), for: .normal)
            }
        }

        titleLabel.text = pinDetail.title
        pinratingCount.text = "(" + "\(pinDetail.ratedTimes)" + ")"
//        pinTypeAndCheckInCount.text = pinDetail.type.capitalized + " • " + "\(pinDetail.visitedCount)" + " check-ins"
         pinTypeAndCheckInCount.text = pinDetail.type.capitalized
        
        if pinDetail.description == ""{
            self.descriptionContentView.isHidden = true
        }else{
            self.descriptionContentView.isHidden = false
            pinDescription.text = pinDetail.description
        }
        if pinDetail.notes == ""{
            self.noteContentView.isHidden = true
        }else{
             self.noteContentView.isHidden = false
            noteForPin.text = pinDetail.notes
        }
        print("videoLink is " + pinDetail.videoLink)
        if pinDetail.videoLink == ""{
            self.videoLinkContentView.isHidden = true
        }else{
            self.videoLinkContentView.isHidden = false
            videoLink.text = pinDetail.videoLink
        }
        
        let createdUser = pinDetail.user.photoUrl
        if let imaegURL = URL(string: createdUser){
            createdByImageView.sd_setImage(with: imaegURL, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        createdByName.text = pinDetail.user.name
        let dateInSeconds = Double(pinDetail.creationTime / 1000)
        let date = Date(timeIntervalSince1970: dateInSeconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        createdDate.text = dateFormatter.string(from: date)
        if DataManager.isLogin! {
            if pinDetail.user.uid == DataManager.userId!{
                self.ratingContentView.isHidden = true
            }else{
                ratingContentView.isHidden = false
//                if isVisitedPin{
//                    ratingContentView.isHidden = false
//                }else{
//                    ratingContentView.isHidden = true
//                }
            }
        }
        else {
            
        }
       
    }

}
