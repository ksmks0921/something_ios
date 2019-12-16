//
//  HomeVC.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import CoreLocation
import FAPanels
import GoogleMaps
import Firebase

class HomeVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var pinsView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var colectionView: UICollectionView!
//    @IBOutlet weak var showHideButton: MSBButton!
    @IBOutlet weak var showHideButton: MSBButton!
    
    //MARK:- Variables
    var isLocationUpdated = false
    var currentIndex = IndexPath()
    var isVisitedPin = false
    var isMissedPin = false
    var ref : DatabaseReference!
    var filteredArray = [PinsSnapShot]()
    var zoom = 15.0
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDetail(_ :)), name: NSNotification.Name.init("FirstUpdate"), object: nil)
        ref = Database.database().reference()
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        if (DataManager.selectedMap ?? "0") == "0"{
            mapView.mapType = .satellite
        }else if (DataManager.selectedMap ?? "0") == "1"{
            mapView.mapType = .normal
        }else{
            mapView.mapType = .hybrid
        }
       
        
    }
    
    @objc func updateDetail(_ sender: Notification){
        updatePins()
    }
    
    func updatePins(){
        mapView.camera = GMSCameraPosition.camera(withTarget: globleCurrentLocation, zoom: 15)
        CreatePinVM.shared.getPins(completion: { success in
            self.filteredArray = CreatePinVM.shared.pinsData
            if self.filteredArray.count > 0{
                self.setMArkers(selectedPin: self.filteredArray[0])
            }
//            self.showHideButton.isHidden = false
            self.colectionView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updatePins()
    }
    
    //MARK:- IBActions
    @IBAction func notificatinButton(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.present(VC, animated: true, completion: nil)
    }
    @IBAction func zoomOutButton(_ sender: Any) {
        zoom = zoom - 1
        self.mapView.animate(toZoom: Float(zoom))
    }
    
    @IBAction func zoomInButton(_ sender: Any) {
        zoom = zoom + 1
        self.mapView.animate(toZoom: Float(zoom))
    }
    
    @IBAction func mapTypeButton(_ sender: Any) {
        self.showAlert(message: "", title: "Choose map type", otherButtons: [ "Satellite" :{ (action) in
            DataManager.selectedMap = "0"
            self.mapView.mapType = .satellite
            },
                                                                              "Map":{(action) in
                                                                                self.mapView.mapType = .normal
                                                                                DataManager.selectedMap = "1"
            },
                                                                              "Hybrid" : {(action) in
                                                                                self.mapView.mapType = .hybrid
                                                                                DataManager.selectedMap = "2"
            }], cancelTitle: "Cancel", cancelAction: nil)
    }
    
    @IBAction func mycurrentLocationButton(_ sender: Any) {
        if globleCurrentLocation.latitude != 0.0{
            mapView.animate(to: GMSCameraPosition.camera(withTarget: globleCurrentLocation, zoom: 15))
        }
    }
    
    @IBAction func menuButton(_ sender: Any) {
        
        panel?.openLeft(animated: true)
    }
    
    @IBAction func filterButtonAction(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "FiltersVC") as! FiltersVC
        VC.delegate = self
        self.present(VC, animated: true, completion: nil)
    }
    
    @IBAction func openCollectionView(_ sender: Any) {
        self.showColectionView()
    }
    @IBAction func addmarkerButton(_ sender: Any) {
        
        if DataManager.isLogin!{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "AddPinVC") as! AddPinVC
            VC.currentLocation = globleCurrentLocation
            self.present(VC, animated: true, completion: nil)
            
        
        }
        else {
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
        
    }
    //MARK:- Custom Methods
    
    @IBAction func showQ(_ sender: Any) {
        showColectionView()
    }
    func showColectionView(){
        self.pinsView.isHidden = false
//        self.showHideButton.isHidden = true
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.pinsView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }

    func hideColectionView(){
//        self.showHideButton.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.pinsView.transform = CGAffineTransform(translationX: 0, y: 250)
        }, completion: nil)
    }


    func setMArkers(selectedPin : PinsSnapShot){
        mapView.clear() 
        for pinData in filteredArray{
            let pinType = pinData.type
            let lat = Double(pinData.coordinates.lat)
            let long = Double(pinData.coordinates.lon)
            let marker = GMSMarker()
            
            if pinData.key == selectedPin.key{
                if pinType == FireBaseConstant.MarkerType.ATTRACTION.rawValue{
                    marker.icon = #imageLiteral(resourceName: "orangemarker")
                }
                if pinType == FireBaseConstant.MarkerType.EVENT.rawValue{
                    marker.icon = #imageLiteral(resourceName: "bluemarker")
                }
                if pinType == FireBaseConstant.MarkerType.HISTORICAL.rawValue{
                    marker.icon = #imageLiteral(resourceName: "placeholder (3)")
                }
                if pinType == FireBaseConstant.MarkerType.OFFER.rawValue{
                    marker.icon = #imageLiteral(resourceName: "orangemarker")
                }
                if pinType == FireBaseConstant.MarkerType.EXPERIENCE.rawValue{
                    marker.icon = #imageLiteral(resourceName: "purplemarker")
                }
                if pinType == FireBaseConstant.MarkerType.VIEWPOINT.rawValue{
                    marker.icon = #imageLiteral(resourceName: "greenmaker")
                }
            }else{
                marker.icon = #imageLiteral(resourceName: "maps-and-flags")
            }
            
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long )
            marker.map = mapView
        }
    }
    
}

//MARK:- CollectionView Methods
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageCell", for: indexPath) as! HomePageCell
        let pinDetail = filteredArray[indexPath.item]
        var uri = ""
        if let mediaItem  = pinDetail.media{
            for data in mediaItem{
                uri = data.uri
            }
        }
        if let imageUrl = URL(string: uri){
            cell.locationImage.sd_setImage(with: imageUrl, completed: nil)
        }
        let coordinate = pinDetail.coordinates
        
        let locationLatLong = CLLocation(latitude: coordinate.lat, longitude: coordinate.lon)
        let distance = locationLatLong.distance(from: CLLocation(latitude: globleCurrentLocation.latitude, longitude: globleCurrentLocation.longitude))
        let yard = Int(distance / 1.09361)
        cell.distanceLabel.text = "\(yard) yd"
        cell .checkInCountLabel.text = "\(pinDetail.visitedCount) check-ins"
        cell.markerType.text = pinDetail.type.capitalized
        
        CreatePinVM.shared.searchForFav(pinId: pinDetail.key) { (success) in
            if success{
//                cell.wishListImageView.image = #imageLiteral(resourceName: "wishlist")
            }else{
//                cell.wishListImageView.image = #imageLiteral(resourceName: "wishlist (1)")
            }
        }
        if DataManager.isLogin!{
            if pinDetail.user.uid == DataManager.userId!{
                cell.editView.isHidden = false
//                cell.wishListView.isHidden = true
//                cell.checkInView.isHidden = true
            }else{
                cell.editView.isHidden = true
//                cell.wishListView.isHidden = false
                UpdatePinVM.shared.isMissedPin(pinId: pinDetail.key) { (success) in
                    self.isMissedPin = success
                    if success{
//                        cell.checkInView.isHidden = false
                    }else{
//                        cell.checkInView.isHidden = true
                    }
                    if !self.isMissedPin{
                        if yard > 109 {
//                            cell.checkInView.isHidden = true
                        }else{
//                            cell.checkInView.isHidden = false
                        }
                    }
                }
            }
        }
        
        
        
        UpdatePinVM.shared.isPinVisited(pinId: pinDetail.key) { (success) in
            self.isVisitedPin = success
            if success{
//                cell.checkInView.isHidden = false
//                cell.checkInImageView.image = #imageLiteral(resourceName: "location_Green")
            }else{
//                cell.checkInImageView.image = #imageLiteral(resourceName: "location_right_icon-1")
            }
        }
        
        
//        cell.markerButton.tag = (indexPath.section * 1000) + indexPath.item
//        cell.markerButton.addTarget(self, action: #selector(self.checkInButtonAction(_:)), for: .touchUpInside)
        
        cell.infoButton.addTarget(self, action: #selector(self.infoButtonAction(_:)), for: .touchUpInside)
        cell.infoButton.tag = (indexPath.section * 1000) + indexPath.item
        
//        cell.favouriteButton.addTarget(self, action: #selector(self.favButtonAtion(_:)), for: .touchUpInside)
//        cell.favouriteButton.tag = (indexPath.section * 1000) + indexPath.item
        
        cell.navigationButton.addTarget(self, action: #selector(self.navigationButtonAtion(_:)), for: .touchUpInside)
        cell.navigationButton.tag = (indexPath.section * 1000) + indexPath.item
        
//        cell.shareButton.tag =  (indexPath.section * 1000) + indexPath.item
//        cell.shareButton.addTarget(self, action: #selector(self.shareButtonAction(_:)), for: .touchUpInside)
        
        cell.editButton.tag = (indexPath.section * 1000) + indexPath.item
        cell.editButton.addTarget(self, action: #selector(self.editButtonAction(_:)), for: .touchUpInside)
        
        cell.locationTitle.text = pinDetail.title
        cell.ratingView.isEnabled = false
        cell.ratingView.value = CGFloat(pinDetail.rating)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "PinInfoMainVC") as! PinInfoMainVC
        VC.pinDetail = filteredArray[indexPath.item]
        VC.isMissedPin = self.isMissedPin
        VC.isVisitedPin = self.isVisitedPin
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: UIScreen.main.bounds.width - 40, height: 230)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth:Float = Float(UIScreen.main.bounds.width - 20);
        let currentOffSet:Float = Float(scrollView.contentOffset.x)
        let targetOffSet:Float = Float(targetContentOffset.pointee.x)
        var newTargetOffset:Float = 0
        if(targetOffSet > currentOffSet){
            newTargetOffset = ceilf(currentOffSet / pageWidth) * pageWidth
        }else{
            newTargetOffset = floorf(currentOffSet / pageWidth) * pageWidth
        }
        if(newTargetOffset < 0){
            newTargetOffset = 0;
        }else if (newTargetOffset > Float(scrollView.contentSize.width)){
            newTargetOffset = Float(scrollView.contentSize.width)
        }
        targetContentOffset.pointee.x = CGFloat(currentOffSet)
        scrollView.setContentOffset(CGPoint.init(x: Int(newTargetOffset), y: 0), animated: true)
    }
    
   
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = colectionView.contentOffset
        visibleRect.size = colectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = colectionView.indexPathForItem(at: visiblePoint)
        guard let indexPath = visibleIndexPath else { return }
        let coordinate = filteredArray[indexPath.item].coordinates
        self.setMArkers(selectedPin: filteredArray[indexPath.item])
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.lat, longitude: coordinate.lon, zoom: self.mapView.camera.zoom)
        mapView.animate(to: camera)
        
    }
    
    
}
//MARK:- cellButtonAction
extension HomeVC{
    
    @objc func infoButtonAction(_ sender: UIButton){
        let buttonTag = sender.tag
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "PinInfoMainVC") as! PinInfoMainVC
        VC.pinDetail = filteredArray[buttonTag]
        VC.currentLocation = globleCurrentLocation
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc func favButtonAtion(_ sender: UIButton){
        let buttonTag = sender.tag
        let pinId = filteredArray[buttonTag].key
        let row = sender.tag % 1000
        let section = sender.tag / 1000
        let cell = colectionView.cellForItem(at: IndexPath(item: row, section: section)) as! HomePageCell
//        if cell.wishListImageView.image == #imageLiteral(resourceName: "wishlist (1)"){
//            CreatePinVM.shared.AddwishList(pinId: pinId)
//            cell.wishListImageView.image = #imageLiteral(resourceName: "wishlist")
//        }else{
//            CreatePinVM.shared.removeFromWishList(pinId: pinId)
//            cell.wishListImageView.image = #imageLiteral(resourceName: "wishlist (1)")
//        }
        
    }
    
    @objc func shareButtonAction(_ sender: UIButton){
        let firstActivityItem = "something://"
        let activityViewController = UIActivityViewController(
            activityItems: [firstActivityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        self.present(activityViewController, animated: true, completion: nil)

    }
    

    
    @objc func navigationButtonAtion(_ sender: UIButton){
        //open google maps if availbale
        let index = sender.tag
        let coordiantes = filteredArray[index].coordinates
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                "https://www.google.com/maps/dir/?api=1&destination=\(coordiantes.lat),\(coordiantes.lon)")!)
        }
            //open apple maps
        else{
            let url = "http://maps.apple.com/?saddr=\(globleCurrentLocation.latitude),\(globleCurrentLocation.longitude)&daddr=\(coordiantes.lat),\(coordiantes.lon)"
            UIApplication.shared.openURL(URL(string:url)!)
        }
    }
    
    @objc func checkInButtonAction(_ sender : UIButton){
        let buttonTag = sender.tag
        let row = buttonTag % 1000
        let cell = colectionView.cellForItem(at: IndexPath(item: row, section: 0)) as! HomePageCell
        if cell.checkInImageView.image != #imageLiteral(resourceName: "location_Green"){
            let pindata = filteredArray[buttonTag]
            UpdatePinVM.shared.updatePinVisited(pin: pindata)
            cell.checkInImageView.image = #imageLiteral(resourceName: "location_Green")
        }
        
    }
    
    @objc func editButtonAction(_ sender : UIButton){
        let buttonTag = sender.tag
        let row = buttonTag % 1000
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "EditPinVC") as! EditPinVC
        VC.pinDetail = filteredArray[row]
        self.present(VC , animated: true, completion: nil)
    }
}


//MARK:- MapView Delagate
extension HomeVC: GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.hideColectionView()
    }
    
   
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.showColectionView()
        return true
    }
}


//MARK:- Filter Delegate
extension HomeVC : FilterDelegate{
    func filter(pinsRequired: [String]) {
        filteredArray  = CreatePinVM.shared.pinsData.filter { (pin) -> Bool in
            for pinsType in pinsRequired{
                if pinsType == pin.type{
                    return true
                }else{
                    return false
                }
            }
            return true
        }
        colectionView.reloadData()
    }
}




