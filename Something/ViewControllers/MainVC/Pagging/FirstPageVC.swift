//
//  FirstPageVC.swift
//  Something
//
//  Created by Maninder Singh on 25/02/18.
//  Copyright © 2018 Maninder Singh. All rights reserved.
//

import UIKit

class FirstPageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func nextButton(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("next"), object: nil)
    }
}
