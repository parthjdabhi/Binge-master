//
//  EmailViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/28/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EmailViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!

    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        emailField.setPlaceholderColor()
        passwordField.setPlaceholderColor()
        emailField.setLeftMargin(20)
        passwordField.setLeftMargin(20)
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        self.background.fadeOut(completion: {
            (finished: Bool) -> Void in
            self.background.fadeIn()
        })
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            self.view.endEditing(true)
            self.goNextSelectorClosure?()
        }
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == emailField {
            animateViewMoving(16)
        } else if textField == passwordField {
            animateViewMoving(88)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField == emailField {
            animateViewMoving(16,up: false)
        } else if textField == passwordField {
            animateViewMoving(88,up: false)
        }
    }
    
    @IBAction func didEnterEmail(sender: AnyObject) {
         TermsViewController.emailAddress = self.emailField.text!
    }
    
    @IBAction func didEnterPassword(sender: AnyObject) {
        TermsViewController.userPassword = self.passwordField.text!
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
