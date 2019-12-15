//
//  SetLocationVC.swift
//  Something
//
//  Created by Maninder Singh on 27/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import GoogleMaps

protocol getLatLongFromLocationVCDeleagate {
    func getlatLong(location : CLLocationCoordinate2D)
}

class SetLocationVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var mapView: GMSMapView!
    
    //MARK:- Variables
    let gmsMarker = GMSMarker()
    var currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var isLocationUpdated = false
    var delegate : getLatLongFromLocationVCDeleagate?
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.mapType = .satellite
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude,longitude: currentLocation.longitude, zoom: 15)
        gmsMarker.position = currentLocation
        gmsMarker.map = mapView
    }
    //MARK:- IBActions
    @IBAction func setlocationButton(_ sender: Any) {
        delegate?.getlatLong(location: currentLocation)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
   
    //MARK:- Custom Methods


}


//MARK:- MapView Delagate
extension SetLocationVC : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        currentLocation = coordinate
        gmsMarker.position = coordinate
        gmsMarker.map = mapView
        
    }
}
