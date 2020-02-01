//
//  MyProfileVC.swift
//  Something
//
//  Created by Maninder Singh on 14/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit
import FirebaseStorage

class MyProfileVC: BaseVC {
    //MARK:- IBOutlets
    
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var webTF: UITextField!
    
    //MARK:- Variables
        let imagePicker = UIImagePickerController()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        if let urlImage = URL(string: DataManager.UserImageURL ?? ""){
            myProfileImage.sd_setImage(with: urlImage, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        nameTF.text = DataManager.name ?? ""
        locationTF.text = DataManager.location ?? ""
        webTF.text = DataManager.webAddress ?? ""
    }
    
    //MARK:- IBActions
    
    @IBAction func editImageButton(_ sender: Any) {
        
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
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if nameTF.isEmpty{
            self.showAlert(message: "Please enter name.")
            return
        }
        updateprofile()
        
    }
    
    //MARK:- Custom Methods

    

}
//MARK:- ImagePicker
extension MyProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
extension MyProfileVC{
    func uploadMedia(image: UIImage) {
        Indicator.sharedInstance.showIndicator()
        let storageRef = Storage.storage().reference().child("media").child(UUID().uuidString)
        if let uploadData = UIImagePNGRepresentation(image) {
            
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                Indicator.sharedInstance.hideIndicator()
                if error != nil {
                    print("error")
                    
                } else {
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {return}
                        UserVM.shared.updateImage(imageUrl: downloadURL.absoluteString)
                    }
                   
                    //UserVM.shared.updaeImage(imageUrl: (metadata?.downloadURL()?.absoluteString)!)
                    //completion((metadata?.downloadURL()?.absoluteString)!))
                    // your uploaded photo url.
                }
            }
        }
    }
}

//MARK:- Firebase Methods
extension MyProfileVC{
    func updateprofile(){
        UserVM.shared.editProfile(name: nameTF.text!, location: locationTF.text ?? "" , webaddress: webTF.text ?? "")
        self.navigationController?.popViewController(animated: true)
    }
    
}
