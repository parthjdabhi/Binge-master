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
        
        let paddingView = UIView(frame:CGRectMake(0, 0, 30, 30))
        emailField.leftView = paddingView;
        emailField.leftViewMode = UITextFieldViewMode.Always
        emailField.text = "Email Address"
        emailField.textColor = UIColor.whiteColor()
        passwordField.text = "Password"
        passwordField.textColor = UIColor.whiteColor()
        let paddingForFirst = UIView(frame: CGRectMake(0, 0, 30, self.passwordField.frame.size.height))
        //Adding the padding to the second textField
        passwordField.leftView = paddingForFirst
        passwordField.leftViewMode = UITextFieldViewMode .Always
        
        passwordField.font = UIFont(name: passwordField.font!.fontName, size: 15)
        
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.emailField.text = ""
        self.passwordField.text = ""
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
