//
//  AddPinVC.swift
//  Something
//
//  Created by Maninder Singh on 26/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import FirebaseStorage


class AddPinVC: BaseVC {

    //MARK:- IBOutlets
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var pinTitle: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var descriptionTF: UITextField!
//    @IBOutlet weak var noteTF: UITextField!
    @IBOutlet weak var noteTF: UITextField!
//    @IBOutlet weak var videoLink: UITextField!
    @IBOutlet weak var videoLink: UITextField!
    @IBOutlet weak var attactionButton: UIImageView!
    @IBOutlet weak var eventButton: UIImageView!
    @IBOutlet weak var HisticalButton: UIImageView!
//    @IBOutlet weak var experianceButton: UIImageView!
//    @IBOutlet weak var viewPointButton: UIImageView!
    
    //MARK:- Variables
    let gmsMarker = GMSMarker()
    var currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var isLocationUpdated = false
    var selectedMark = FireBaseConstant.MarkerType.EVENT.rawValue
    var ImagesArr = [UIImage]()
    let imagePicker = UIImagePickerController()
    var imagesUrls = [URL]()
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        mapView.settings.setAllGesturesEnabled(false)
        mapView.mapType = .satellite
        getlatLong(location: currentLocation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK:- IBActions
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectLocationButtonMap(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationVC
        VC.delegate = self
        VC.currentLocation = currentLocation
        self.present(VC, animated: true, completion: nil)
    }
    
    @IBAction func finishbutton(_ sender: Any) {
        if pinTitle.isEmpty{
            self.showAlert(message: "Please enter title of the pin.")
            return
        }
        if currentLocation.latitude == 0.0{
            self.showAlert(message: "Please check your location.")
            return
        }
        CreatePin()
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageButton(_ sender: Any) {
        
    }
    
    @IBAction func setlocatonMapButton(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationVC
        VC.delegate = self
        VC.currentLocation = currentLocation
        self.present(VC, animated: true, completion: nil)
    }
    
    @IBAction func attractionButton(_ sender: Any) {
        attactionButton.image = #imageLiteral(resourceName: "s_greenmaker")
        eventButton.image = #imageLiteral(resourceName: "maps-and-flags")
//        experianceButton.image = #imageLiteral(resourceName: "maps-and-flags")
        HisticalButton.image = #imageLiteral(resourceName: "maps-and-flags")
//        viewPointButton.image = #imageLiteral(resourceName: "maps-and-flags")
        selectedMark = FireBaseConstant.MarkerType.ATTRACTION.rawValue
        
    }
    
    @IBAction func eventButton(_ sender: Any) {
        attactionButton.image = #imageLiteral(resourceName: "maps-and-flags")
        eventButton.image = #imageLiteral(resourceName: "s_orangemarker")
//        experianceButton.image = #imageLiteral(resourceName: "maps-and-flags")
        HisticalButton.image = #imageLiteral(resourceName: "maps-and-flags")
//        viewPointButton.image = #imageLiteral(resourceName: "maps-and-flags")
        selectedMark = FireBaseConstant.MarkerType.EVENT.rawValue
    }
    
    @IBAction func experianceButton(_ sender: Any) {
        attactionButton.image = #imageLiteral(resourceName: "maps-and-flags")
        eventButton.image = #imageLiteral(resourceName: "maps-and-flags")
//        experianceButton.image = #imageLiteral(resourceName: "s_purplemarker")
        HisticalButton.image = #imageLiteral(resourceName: "maps-and-flags")
//        viewPointButton.image = #imageLiteral(resourceName: "maps-and-flags")
        selectedMark = FireBaseConstant.MarkerType.EXPERIENCE.rawValue
    }
    
    @IBAction func histoicalButton(_ sender: Any) {
        attactionButton.image = #imageLiteral(resourceName: "maps-and-flags")
        eventButton.image = #imageLiteral(resourceName: "maps-and-flags")
//        experianceButton.image = #imageLiteral(resourceName: "maps-and-flags")
        HisticalButton.image = #imageLiteral(resourceName: "s_bluemarker")
//        viewPointButton.image = #imageLiteral(resourceName: "maps-and-flags")
        selectedMark = FireBaseConstant.MarkerType.HISTORICAL.rawValue
    }
    
    @IBAction func viewPointButton(_ sender: Any) {
        attactionButton.image = #imageLiteral(resourceName: "maps-and-flags")
        eventButton.image = #imageLiteral(resourceName: "maps-and-flags")
//        experianceButton.image = #imageLiteral(resourceName: "maps-and-flags")
        HisticalButton.image = #imageLiteral(resourceName: "maps-and-flags")
//        viewPointButton.image = #imageLiteral(resourceName: "s_greenmaker")
        selectedMark = FireBaseConstant.MarkerType.VIEWPOINT.rawValue
    }
    
    //MARK:- Custom Methods
    
    
    func setMarkerColor(markerType : FireBaseConstant.MarkerType) -> UIImage{
        switch markerType {
            case .EVENT:
                return #imageLiteral(resourceName: "bluemarker")
                
            case .HISTORICAL:
                return  #imageLiteral(resourceName: "placeholder (3)")
                
            case .VIEWPOINT:
                return #imageLiteral(resourceName: "greenmaker")
                
            case .OFFER:
                return #imageLiteral(resourceName: "orangemarker")
                
            case .ATTRACTION:
                return #imageLiteral(resourceName: "orangemarker")
                
            case .EXPERIENCE:
                return #imageLiteral(resourceName: "purplemarker")
                
            }
    }
    
    @objc func addImage(_ sender : UIButton){
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ UIAlertAction in
            if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }else{
                self.showAlert(message: "You don't have camera")
            }
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: .default){ UIAlertAction in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ UIAlertAction in
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
}


//MARK:- Firebase Methods
extension AddPinVC{
    func CreatePin(){
        CreatePinVM.shared.setUpUserPinNote(title: self.pinTitle.text! , pinType: selectedMark, activityType: FireBaseConstant.ActivityType.PIN_CREATED.hashValue, description: descriptionTF.text ?? "", notes: noteTF.text ?? "", videoLink: videoLink.text ?? "", pinLocation: currentLocation, urls: imagesUrls)
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK:- CollectionView methods
extension AddPinVC: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ImagesArr.count == 0{
            return 1
        }else{
            return ImagesArr.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellWithButton", for: indexPath) as! CellWithButton
            cell.addButton.addTarget(self, action: #selector(self.addImage(_:)), for: .touchUpInside)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellWithImage", for: indexPath) as! CellWithImage
            cell.Image.image = ImagesArr[indexPath.item - 1]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0{
            let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: .default){ UIAlertAction in
                if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                    self.imagePicker.sourceType = .camera
                }else{
                    self.showAlert(message: "You don't have camera")
                }
            }
            let gallaryAction = UIAlertAction(title: "Gallary", style: .default){ UIAlertAction in
                self.imagePicker.sourceType = .photoLibrary
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ UIAlertAction in
            }
            // Add the actions
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK:- ImagePicker
extension AddPinVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let myImage = info[UIImagePickerControllerEditedImage] as? UIImage
        uploadMedia(image: myImage!)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//Mark:- Upload Images
extension AddPinVC{
    func uploadMedia(image: UIImage) {
        Indicator.sharedInstance.showIndicator()
        let storageRef = Storage.storage().reference().child("media").child(UUID().uuidString)
        if let uploadData = UIImagePNGRepresentation(image) {
            
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                Indicator.sharedInstance.hideIndicator()
                if error != nil {
                    print("error")
                    
                } else {
                    self.ImagesArr.append(image)
                    self.imagesCollectionView.reloadData()
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {return}
                        self.imagesUrls.append(downloadURL.absoluteURL)
                    }
                    //completion((metadata?.downloadURL()?.absoluteString)!))
                    // your uploaded photo url.
                }
            }
        }
    }
}


//MARK:- Set Locaiton Delatgate
extension AddPinVC : getLatLongFromLocationVCDeleagate{
    func getlatLong(location: CLLocationCoordinate2D) {
        mapView.clear()
        mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: 15)
        currentLocation = location
        gmsMarker.position = location
        gmsMarker.map = mapView
    }
    
    
}
