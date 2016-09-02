//
//  DOBViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/28/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class DOBViewController: BaseViewController {

    @IBOutlet var datePickView: UIDatePicker!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!

    override func viewDidLoad() {
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.background.fadeOut(completion: {
            (finished: Bool) -> Void in
            self.background.fadeIn()
        })
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    class ColoredDatePicker: UIDatePicker {
        var changed = false
        override func addSubview(view: UIView) {
            if !changed {
                changed = true
                self.setValue(UIColor.whiteColor(), forKey: "textColor")
            }
            super.addSubview(view)
        }
    }
    
    @IBAction func datePicker(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let strDate = dateFormatter.stringFromDate(datePickView.date)
        TermsViewController.dateOfBirth = strDate
    }
    
    @IBAction func backButton(sender: AnyObject) {
         self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}
