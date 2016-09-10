//
//  NameViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/28/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NameViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate {
    
    

    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    var ref:FIRDatabaseReference!
    var user: FIRUser!

    override func viewDidLoad() {
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser

        firstNameField.setPlaceholderColor()
        lastNameField.setPlaceholderColor()
        firstNameField.setLeftMargin(20)
        lastNameField.setLeftMargin(20)

        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        
        //self.saveData()
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            self.view.endEditing(true)
            self.goNextSelectorClosure?()
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == firstNameField {
            animateViewMoving(16)
        } else if textField == lastNameField {
            animateViewMoving(26)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField == firstNameField {
            animateViewMoving(16,up: false)
        } else if textField == lastNameField {
            animateViewMoving(26,up: false)
        }
    }
    
    @IBAction func firstNameEntry(sender: AnyObject) {
        TermsViewController.firstName = self.firstNameField.text!
    }
    
    @IBAction func lastNameEntry(sender: AnyObject) {
        TermsViewController.lastName = self.lastNameField.text!
    }
    
    @IBAction func backButton(sender: AnyObject) {
         self.navigationController?.popViewControllerAnimated(true)
    }
    
}
