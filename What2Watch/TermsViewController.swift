//
//  TermsViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/29/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SWRevealViewController

class TermsViewController: BaseViewController, UIPageViewControllerDelegate {

    @IBOutlet var checkbox: UIButton!
    @IBOutlet var getStarted: UIButton!
    @IBOutlet var getStartedText: UIImageView!
    @IBOutlet var forwardArrow: UIImageView!
    @IBOutlet var approvedCheckbox: UIButton!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    static var emailAddress:String = ""
    static var userPassword:String = ""
    static var firstName:String = ""
    static var lastName:String = ""
    static var picture:String = ""
    static var sex:String = ""
    static var origin:String = ""
    static var dateOfBirth:String = ""
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        getStarted.hidden = true
        getStartedText.hidden = true
        forwardArrow.hidden = true
        approvedCheckbox.hidden = true
        
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
    
    @IBAction func approvedButton(sender: AnyObject) {
        getStarted.hidden = false
        getStartedText.hidden = false
        forwardArrow.hidden = false
        approvedCheckbox.hidden = false
        
        self.delegate.hiddenPageController();
    }
    
    @IBAction func unApproveButton(sender: AnyObject) {
        getStarted.hidden = true
        getStartedText.hidden = true
        forwardArrow.hidden = true
        approvedCheckbox.hidden = true
    }
    
    @IBAction func getStartedButton(sender: AnyObject)
    {
        
        let emailInfo : String = String(TermsViewController.emailAddress)
        let passwordInfo : String = String(TermsViewController.userPassword)
        let firstNameInfo : String = String(TermsViewController.firstName)
        let lastNameInfo : String = String(TermsViewController.lastName)
        let userPicture : String = String(TermsViewController.picture)
        let userDOB : String = String(TermsViewController.dateOfBirth)
        let userOrigin : String = String(TermsViewController.origin)
        let userSex : String = String(TermsViewController.sex)
        print(userSex)
        print(userOrigin)
        print(userDOB)
        print(emailInfo)
        print(passwordInfo)
        print(firstNameInfo)
        print(lastNameInfo)
        print(userPicture)
        if firstNameInfo == "" && firstNameInfo == "" {
            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Required your firstname & lastname.")
            return
        }
//        else if emailInfo == "" {
//            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Please select the photo")
//            return
//        }
        else if emailInfo == "" && passwordInfo == "" {
            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Required your email address and password.")
            return
        }
        else if passwordInfo.characters.count < 6 {
            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Your password should be of atleast six character long.")
            return
        }
        else
        {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(emailInfo, password: passwordInfo, completion:  { (user, error) in
                if error == nil
                {
                    FIREmailPasswordAuthProvider.credentialWithEmail(emailInfo, password: passwordInfo)
                    self.ref.child("users").child(user!.uid).setValue(["userFirstName": firstNameInfo, "userLastName": lastNameInfo, "userGender": userSex, "userNationality": userOrigin, "userDOB": userDOB, "email": emailInfo])
                    
                    if userPicture != "" {
                        self.ref.child("users").child(user!.uid).child("image").setValue(userPicture)
                    }
                    
                    CommonUtils.sharedUtils.hideProgress()
                    
                    self.performSegueWithIdentifier("segueMainScreen", sender: self)
                    
                    //let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                    //self.navigationController?.pushViewController(mainViewController, animated: true)
                    
                    //let RevealViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
                    //self.navigationController?.pushViewController(RevealViewController, animated: true)
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        CommonUtils.sharedUtils.hideProgress()
                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    })
                }
            })
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
         self.navigationController?.popViewControllerAnimated(true)
    }
    
}
