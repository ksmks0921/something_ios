//
//  uploadSponserVC.swift
//  Something
//
//  Created by Panda Star on 1/31/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import Braintree


class uploadSponserVC: UIViewController {

    var braintreeClient: BTAPIClient!
    
   
    @IBOutlet weak var imageBtn: MSBButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        braintreeClient = BTAPIClient(authorization: "sandbox_ndsc8j7n_6mcmtxdthcvq2twh")
       
        
    }
    
    @IBAction func addImageBtnTapped(_ sender: Any) {
        showImagePickerControllerActionSheet()
    }
    @IBAction func clickedBtnPay(_ sender: Any) {
        
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
               payPalDriver.viewControllerPresentingDelegate = self as! BTViewControllerPresentingDelegate
               payPalDriver.appSwitchDelegate = self as! BTAppSwitchDelegate
               
               let request = BTPayPalRequest(amount: "2.32")
                      request.currencyCode = "USD" // Optional; see BTPayPalRequest.h for more options

                      payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
                          if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                              print("Got a nonce: \(tokenizedPayPalAccount.nonce)")

                              // Access additional information
                              let email = tokenizedPayPalAccount.email
                              print("________payment email______________")
                              debugPrint(email)
                              let firstName = tokenizedPayPalAccount.firstName
                              let lastName = tokenizedPayPalAccount.lastName
                              let phone = tokenizedPayPalAccount.phone

                              // See BTPostalAddress.h for details
                              let billingAddress = tokenizedPayPalAccount.billingAddress
                              let shippingAddress = tokenizedPayPalAccount.shippingAddress
                          } else if let error = error {
                                print(error)
                              // Handle error here...
                          } else {
                              // Buyer canceled payment approval
                          }
                      }
        
        
        
    }
    


}

extension uploadSponserVC: BTViewControllerPresentingDelegate {
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
    
    
}

extension uploadSponserVC: BTAppSwitchDelegate{
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
    
    
}

extension uploadSponserVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerControllerActionSheet(){
        
        let photoLibraryAction = UIAlertAction(title: "Choose from library", style:  . default){
            (action) in
            
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Choose from camera", style:  . default){
            (action) in
            
            self.showImagePickerController(sourceType: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        AlertService.showAlert(style: . actionSheet, title: "Choose your image", message: nil, actions:[photoLibraryAction, cameraAction, cancelAction], completion: nil)
    }
    
    func showImagePickerController(sourceType:UIImagePickerController.SourceType) {
          let imagePickerController = UIImagePickerController()
          imagePickerController.delegate = self
          imagePickerController.allowsEditing = true
          imagePickerController.sourceType = sourceType
          self.present(imagePickerController, animated: true, completion: nil)
      }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageBtn.setImage(myImage, for: .normal)
        }
        
     
        
        dismiss(animated: true, completion: nil)
        

        
    
    }
}

