//
//  PinsComment.swift
//  Something
//
//  Created by Maninder Singh on 15/03/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class PinsComment: BaseVC {

    //MARK:- IBOutlets
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var noCommentsLabel: UIView!
    @IBOutlet weak var commentContentView: UIView!
    
    //MARK:- Variables
    var pinDetail : PinsSnapShot!
    var isMissedPin = false
    var isVisitedPin = false
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CreatePinVM.shared.getPincomments(pinId: pinDetail.key) { (sucess) in
            if CreatePinVM.shared.pinComments.count == 0{
                self.noCommentsLabel.isHidden = false
            }else{
                self.noCommentsLabel.isHidden = true
                
            }
            if DataManager.isLogin! {
                self.commentContentView.isHidden = false
                self.noCommentsLabel.isHidden = true
//                if self.pinDetail.user.uid == DataManager.userId!{
//                    self.commentContentView.isHidden = false
//                    self.noCommentsLabel.isHidden = true
//                }else{
                    
//                    if self.isVisitedPin{
//                        self.commentContentView.isHidden = false
//                        self.noCommentsLabel.isHidden = true
//                    }else{
//                        self.commentContentView.isHidden = true
//                        self.noCommentsLabel.isHidden = false
//                    }
//                }
            }
            else {
                self.commentContentView.isHidden = true
                self.noCommentsLabel.isHidden = false
            }
          
            
            
            self.commentTableView.reloadData()
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func sendButton(_ sender: Any) {
        if commentTF.isEmpty{
            self.showAlert(message: "Please enter your comment.")
            return
        }
        
        CreatePinVM.shared.addComment(pinId: pinDetail.key, text: commentTF.text!, pin: pinDetail)
        CreatePinVM.shared.getPincomments(pinId: pinDetail.key) { (sucess) in
            self.commentTF.text = ""
            self.commentTableView.reloadData()
        }
    }
    
    //MARK:- Custom Methods


}

extension PinsComment :UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CreatePinVM.shared.pinComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinCommentCell") as! PinCommentCell
        let comment = CreatePinVM.shared.pinComments[indexPath.row]
        let imageString = comment.user.photoUrl
        if let imageURL = URL(string: imageString){
            cell.userImage.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        cell.userName.text = comment.user.name
        cell.comment.text = comment.text
        let dateInSeconds = Double(comment.timestamp / 1000)
        let date = Date(timeIntervalSince1970: dateInSeconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        cell.commentDate.text = dateFormatter.string(from: date)
        
        return cell
    }
}
