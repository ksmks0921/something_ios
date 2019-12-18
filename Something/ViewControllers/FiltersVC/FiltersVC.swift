//
//  FiltersVC.swift
//  Something
//
//  Created by Maninder Singh on 17/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import HCSStarRatingView



protocol FilterDelegate {
    func filter (pinsRequired : [String])
}

class FiltersVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var greenImageView: UIImageView!
    @IBOutlet weak var yellowImageView: UIImageView!
    @IBOutlet weak var purpleImagView: UIImageView!
    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var ornageImageView: UIImageView!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    
    //MARK:- Variables
    var delegate : FilterDelegate?
    var pinTypeArray = [String]()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingView.tintColor = GreenColor
        
    }
    
    //MARK:- IBActions
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        self.delegate?.filter(pinsRequired: pinTypeArray)
        self.dismiss(animated: true, completion: nil)
    }
   
    
    
//    @IBAction func viewButton(_ sender: Any) {
//        if greenImageView.image == #imageLiteral(resourceName: "greenmaker"){
//            greenImageView.image = #imageLiteral(resourceName: "s_greenmaker")
//            addToArry(pinType: FireBaseConstant.MarkerType.VIEWPOINT.rawValue)
//        }else{
//            greenImageView.image = #imageLiteral(resourceName: "greenmaker")
//            removeFromArry(pinType: FireBaseConstant.MarkerType.VIEWPOINT.rawValue)
//        }
//    }
    
    @IBAction func attractionButton(_ sender: Any) {
        if ornageImageView.image == #imageLiteral(resourceName: "orangemarker"){
            ornageImageView.image = #imageLiteral(resourceName: "s_orangemarker")
            addToArry(pinType: FireBaseConstant.MarkerType.ATTRACTION.rawValue)
        }else{
            ornageImageView.image = #imageLiteral(resourceName: "orangemarker")
            removeFromArry(pinType: FireBaseConstant.MarkerType.ATTRACTION.rawValue)
        }
    }
    
    @IBAction func eventButton(_ sender: Any) {
        if blurImageView.image == #imageLiteral(resourceName: "greenmaker"){
            blurImageView.image = #imageLiteral(resourceName: "s_greenmaker")
            addToArry(pinType: FireBaseConstant.MarkerType.EVENT.rawValue)
        }else{
            blurImageView.image = #imageLiteral(resourceName: "greenmaker")
            removeFromArry(pinType: FireBaseConstant.MarkerType.EVENT.rawValue)
        }
    }
    
//    @IBAction func experienceButton(_ sender: Any) {
//        if purpleImagView.image == #imageLiteral(resourceName: "purplemarker"){
//            purpleImagView.image = #imageLiteral(resourceName: "s_purplemarker")
//            addToArry(pinType: FireBaseConstant.MarkerType.EXPERIENCE.rawValue)
//        }else{
//            purpleImagView.image = #imageLiteral(resourceName: "purplemarker")
//            removeFromArry(pinType: FireBaseConstant.MarkerType.EXPERIENCE.rawValue)
//        }
//    }
    
    @IBAction func historyButton(_ sender: Any) {
        if yellowImageView.image == #imageLiteral(resourceName: "bluemarker"){
            yellowImageView.image = #imageLiteral(resourceName: "s_bluemarker")
            addToArry(pinType: FireBaseConstant.MarkerType.HISTORICAL.rawValue)
        }else{
            yellowImageView.image = #imageLiteral(resourceName: "bluemarker")
            removeFromArry(pinType: FireBaseConstant.MarkerType.HISTORICAL.rawValue)
        }
    }
    
     //MARK:- Custom Methods
    
    func addToArry(pinType : String){
        pinTypeArray.append(pinType)
        let unique = Array(Set(pinTypeArray))
        pinTypeArray = unique
    }
    
    func removeFromArry(pinType : String){
        let unique = pinTypeArray.filter { $0 != pinType }
        pinTypeArray = unique
    }
}

