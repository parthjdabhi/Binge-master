//
//  FirebaseSignInViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKShareKit
//import Twitter
//import TwitterKit
//import Fabric
import SWRevealViewController
import SVProgressHUD


@objc(FirebaseSignInViewController)
class FirebaseSignInViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var facebook: UIButton!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet var login: UIButton!
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        view.backgroundColor = UIColor(rgb: 0x282828)
        facebook.hidden = true
        login.layer.borderWidth = 0
        
        emailField.setPlaceholderColor()
        passwordField.setPlaceholderColor()
        emailField.setLeftMargin(10)
        passwordField.setLeftMargin(10)
        emailField.setCornerRadious(6)
        passwordField.setCornerRadious(6)
        login.setCornerRadious(6)
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
                //try! FIRAuth.auth()?.signOut()
//        if let user = FIRAuth.auth()?.currentUser {
//            self.signedIn(user)
//        }
//        ref = FIRDatabase.database().reference()
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            self.view.endEditing(true)
            self.didTapSignIn(nil)
        }
        return false
    }
    
    @IBAction func didTapSignIn(sender: AnyObject?) {
        
        // Sign In with credentials.
        let email = emailField.text!
        let password = passwordField.text!
        if email.isEmpty {
            SVProgressHUD.showInfoWithStatus("Use an appropriate registered email address.")
            //CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Use an appropriate registered email address.")
        }
        else if password.isEmpty || password.characters.count < 6 {
            SVProgressHUD.showInfoWithStatus("Your password should be at least six characters long")
            //CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Your password should be at least six characters long")
        }
        else{
            CommonUtils.sharedUtils.showProgress(self.view, label: "Signing in..")
            FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    CommonUtils.sharedUtils.hideProgress()
                })
                if let error = error {
                    SVProgressHUD.showErrorWithStatus("The username or password you have entered do not correspond with any of our accounts.")
                    //CommonUtils.sharedUtils.showAlert(self, title: "Error", message: "The username or password you have entered do not correspond with any of our accounts.")
                    print(error.localizedDescription)
                }
                else{
                    self.performSegueWithIdentifier("segueMainScreen", sender: self)
                    
//                    let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
//                    self.navigationController?.pushViewController(mainScreenViewController, animated: true)
                }
            }
        }
    }
    @IBAction func didTapSignUp(sender: AnyObject) {
        let signupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! TutorialViewController!
        self.navigationController?.pushViewController(signupViewController, animated: true)
        
    }
    
    func setDisplayName(user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
        changeRequest.commitChangesWithCompletion(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    @IBAction func didRequestPasswordReset(sender: AnyObject) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordResetWithEmail(userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        prompt.addTextFieldWithConfigurationHandler(nil)
        prompt.addAction(okAction)
        presentViewController(prompt, animated: true, completion: nil);
    }
    
    @IBAction func facebookLogin(sender: AnyObject) {
        
        let manager = FBSDKLoginManager()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (result, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error.localizedDescription)
            }
            else if result.isCancelled {
                print("Facebook login cancelled")
            }
            else {
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token)
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information...")
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        CommonUtils.sharedUtils.hideProgress()
                    }
                    else {
                        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,email,gender,friends,picture"])
                        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                            CommonUtils.sharedUtils.hideProgress()
                            if ((error) != nil) {
                                // Process error
                                print("Error: \(error)")
                            } else {
                                print("fetched user: \(result)")
                                self.ref.child("users").child(user!.uid).setValue(["facebookData": ["userFirstName": result.valueForKey("first_name") as! String!, "userLastName": result.valueForKey("last_name") as! String!, "gender": result.valueForKey("gender") as! String!, "email": result.valueForKey("email") as! String!], "userFirstName": result.valueForKey("first_name") as! String!, "userLastName": result.valueForKey("last_name") as! String!, "email": result.valueForKey("email") as! String!])
                                if let picture = result.objectForKey("picture") {
                                    if let pictureData = picture.objectForKey("data"){
                                        if let pictureURL = pictureData.valueForKey("url") {
                                            print(pictureURL)
                                            self.ref.child("users").child(user!.uid).child("facebookData").child("profilePhotoURL").setValue(pictureURL)
                                        }
                                    }
                                }
                                let RevealViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
                                self.navigationController?.pushViewController(RevealViewController, animated: true)
                                
                                //self.performSegueWithIdentifier("segueSetMenu", sender: self)
                                //self.performSegueWithIdentifier("segueMainScreen", sender: self)
                                
//                                let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
//                                self.navigationController?.pushViewController(mainScreenViewController, animated: true)
                            }
                        })
                    }
                })
            }
        }
        
    }
    /*
    @IBAction func twitterLogin(sender: AnyObject) {
        
        let manager = Twitter()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithViewController(self) { (session, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                let token = session!.authToken
                let secret = session!.authTokenSecret
                
                let credential = FIRTwitterAuthProvider.credentialWithToken(token, secret: secret)
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information....")
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        CommonUtils.sharedUtils.hideProgress()
                        print(error?.localizedDescription)
                    }
                    else {
                        let client = TWTRAPIClient.clientWithCurrentUser()
                        let request = client.URLRequestWithMethod("GET",
                            URL: "https://api.twitter.com/1.1/account/verify_credentials.json",
                            parameters: ["include_email": "true", "skip_status":"true"],
                            error: nil)
                        
                        client.sendTwitterRequest(request){ (response, data, connectionError) -> Void in
                            CommonUtils.sharedUtils.hideProgress()
                            let profile = try! NSJSONSerialization.JSONObjectWithData(data!, options: [])
                            print(profile)
                            
                            self.ref.child("users").child(user!.uid).setValue(["twitterData": ["userFirstName": profile.valueForKey("name") as! String!, "userLastName": profile.valueForKey("screen_name") as! String!, "profile_image_url": profile.valueForKey("profile_image_url") as! String!, "url": profile.valueForKey("url") as! String!], "userFirstName": profile.valueForKey("name") as! String!, "userLastName": profile.valueForKey("screen_name") as! String!])
                            let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                            self.navigationController?.pushViewController(mainScreenViewController, animated: true)
                        }
                        
                    }
                })
            }
        }
    }*/
    
    func signedIn(user: FIRUser?) {
        let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
        self.navigationController?.pushViewController(mainScreenViewController, animated: true)
        
        //        MeasurementHelper.sendLoginEvent()
        //
        //        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        //        AppState.sharedInstance.photoUrl = user?.photoURL
        //        AppState.sharedInstance.signedIn = true
        //        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        //        performSegueWithIdentifier(Constants.Segues.AddSocial, sender: nil)
    }
}
