//
//  SignUpViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import OAuthSwift
import SDWebImage
import FirebaseStorage
import ActionSheetPicker_3_0

class SignUpViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate, UITextViewDelegate {
    
    @IBOutlet weak var forwardicon: UIImageView!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var height_const: NSLayoutConstraint!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var facebook: UIButton!
    @IBOutlet var picture: UIImageView!
    @IBOutlet var profilePicture: UIButton!
    @IBOutlet var xIcon: UIImageView!
    @IBOutlet var gender: UIView!
    @IBOutlet var sexes: UIButton!
    @IBOutlet var male: UIButton!
    @IBOutlet var female: UIButton!
    @IBOutlet var nationality: UIButton!
    @IBOutlet weak var pick: UIDatePicker!
    @IBOutlet var genderBottomConstraint: NSLayoutConstraint!
    @IBOutlet var genderBackground: UIImageView!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var dobLabel: UILabel!
    @IBOutlet var nationalityLabel: UILabel!
    @IBOutlet var datePickView: UIDatePicker!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var ref:FIRDatabaseReference!
    var imagePickerController: UIImagePickerController!
    var user: FIRUser!
    var imgTaken = false
    var genderArray = ["Male", "Female"]
    
    @IBOutlet weak var getstartedButton: UIButton!
    override func viewDidLoad() {
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        //picture.layer.borderWidth = 1
        picture.layer.masksToBounds = false
        //picture.layer.borderColor = UIColor.blackColor().CGColor
        picture.layer.cornerRadius = picture.frame.height/2
        picture.clipsToBounds = true
        
        firstNameField.text = "First Name"
        firstNameField.textColor = UIColor.blackColor()
        lastNameField.text = "Last Name"
        lastNameField.textColor = UIColor.blackColor()
        emailField.text = "Email"
        emailField.textColor = UIColor.blackColor()
        passwordField.text = "Password"
        passwordField.textColor = UIColor.blackColor()
        
        genderBackground.layer.borderColor = UIColor.grayColor().CGColor;
        genderBackground.layer.borderWidth = 1
        genderBackground.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue:0.5, alpha: 1.0 ).CGColor;
        nationality.layer.borderColor = UIColor.grayColor().CGColor;
        nationality.layer.borderWidth = 1
        nationality.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue:0.5, alpha: 1.0 ).CGColor;
        firstNameField.layer.borderColor = UIColor.grayColor().CGColor;
        firstNameField.layer.borderWidth = 1
        firstNameField.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue:0.5, alpha: 1.0 ).CGColor;
        lastNameField.layer.borderColor = UIColor.grayColor().CGColor;
        lastNameField.layer.borderWidth = 1
        lastNameField.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue:0.5, alpha: 1.0 ).CGColor;
        scrollView.contentSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height + 10000);
        //        self.height_const.constant=710;
        pick.backgroundColor = UIColor.whiteColor()
        
        //self.saveData()
        
    }
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        //        ref = FIRDatabase.database().reference()
        //        user = FIRAuth.auth()?.currentUser
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func textViewDidBeginEditing(textView: UITextView) {
        self.firstNameField.text = ""
        self.lastNameField.text = ""
        self.emailField.text = ""
        self.passwordField.text = ""
    }
    
    @IBAction func pictureButton(sender: AnyObject) {
                // 1
                view.endEditing(true)
        
                // 2
                let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                               message: nil, preferredStyle: .ActionSheet)
        //        // 3
        //        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
        //            let cameraButton = UIAlertAction(title: "Take Photo",
        //                                             style: .Default) { (alert) -> Void in
        //                                                self.imagePickerController = UIImagePickerController()
        //                                                self.imagePickerController.delegate = self
        //                                                self.imagePickerController.sourceType = .Camera
        //                                                self.presentViewController(self.imagePickerController,
        //                                                                           animated: true,
        //                                                                           completion: nil)
        //            }
        //            imagePickerActionSheet.addAction(cameraButton)
        //        }
                // 4
                let libraryButton = UIAlertAction(title: "Choose Existing",
                                                  style: .Default) { (alert) -> Void in
                                                    self.imagePickerController = UIImagePickerController()
                                                    self.imagePickerController.delegate = self
                                                    self.imagePickerController.sourceType = .PhotoLibrary
                                                    self.presentViewController(self.imagePickerController,
                                                                               animated: true,
                                                                               completion: nil)
                }
                imagePickerActionSheet.addAction(libraryButton)
                // 5
                let cancelButton = UIAlertAction(title: "Cancel",
                                                 style: .Cancel) { (alert) -> Void in
                }
                imagePickerActionSheet.addAction(cancelButton)
                // 6
                presentViewController(imagePickerActionSheet, animated: true,
                                      completion: nil)
        
        self.xIcon.hidden = true
        self.profilePicture.hidden = true
        
        
//        var actionSheet = UIActionSheet()
//        actionSheet = UIActionSheet(title: "image", delegate: self, cancelButtonTitle:"Cancel", destructiveButtonTitle:nil, otherButtonTitles:"select Photo from Library","Take a Picture")
//        actionSheet.delegate = self
//        actionSheet.showInView(self.view)
    }

    
    @IBAction func facebookButton(sender: AnyObject) {
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
                                self.ref.child("users").child(user!.uid).setValue(["facebookData": ["userFirstName": result.valueForKey("first_name") as! String!, "userLastName": result.valueForKey("last_name") as! String!, "gender": result.valueForKey("gender") as! String!, "email": result.valueForKey("email") as! String!], "userFirstName": result.valueForKey("first_name") as! String!, "userLastName": result.valueForKey("last_name") as! String!])
                                if let picture = result.objectForKey("picture") {
                                    if let pictureData = picture.objectForKey("data"){
                                        if let pictureURL = pictureData.valueForKey("url") {
                                            print(pictureURL)
                                            self.ref.child("users").child(user!.uid).child("facebookData").child("profilePhotoURL").setValue(pictureURL)
                                        }
                                    }
                                }
                                let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                                self.navigationController?.pushViewController(mainViewController, animated: true)
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func createProfile(sender: AnyObject) {
        let email = self.emailField.text!
        let password = self.passwordField.text!
        // make sure the user entered both email & password
        if email != "" && password != "" {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion:  { (user, error) in
                if error == nil {
                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
                    self.ref.child("users").child(user!.uid).setValue(["userFirstName": self.firstNameField.text!, "userLastName": self.lastNameField.text!, "userGender": self.genderLabel.text!, "userNationality": self.nationalityLabel.text!, "userDOB": self.dobLabel.text!, "email": email])
                    CommonUtils.sharedUtils.hideProgress()
                    self.performSegueWithIdentifier("segueSetMenu", sender: self)
//                    let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
//                    self.navigationController?.pushViewController(mainViewController, animated: true)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        CommonUtils.sharedUtils.hideProgress()
                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    })
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Enter email & password!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
        }
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.contentMode = .ScaleAspectFit
            picture.image = scaleImage(pickedImage, maxDimension: 300)
        }
        
        self.imgTaken = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        
    }
    
    func imgToBase64(image: UIImage) -> String {
        let imageData:NSData = UIImagePNGRepresentation(image)!
        let base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(base64String)
        
        return base64String
    }
    
    @IBAction func nationalityButton(sender: AnyObject) {
        
        ActionSheetStringPicker.showPickerWithTitle("Where Are You From?", rows: ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua & Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia & Herzegovina", "Botswana", "Brazil", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Costa Rica", "Côte D'Ivoire", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Demorcratic People's Republic of Korea", "Democratic Republic of the Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Savador", "Equatorial Guinea", "Eritrea", "Estonia", "Ehiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Republic of Korea", "Republic of Moldova", "Romania", "Russian Federation", "Rwanda", "Saint Kitts & Nevis", "Saint Lucia", "Saint Vincent & the Grenadines", "Samoa", "San Marino", "Sao Tome & Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Taiwan", "Tajikistan", "Thailand", "The former Yugoslav Republic of Macedonia", "Timor-Leste", "Togo", "Tonga", "Trinidad & Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom of Great Britian & Northern Ireland", "United Republic of Tanzania", "United States of America", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela, Bolivarian Republic of", "Viet Nam", "Yemen", "Zambia", "Zimbabwe"], initialSelection: 187, doneBlock: {

            picker, value, index in
            
            print("value = \(value)")
            print("index = \(index)")
            print("picker = \(picker)")
            self.nationalityLabel.text = ("\(index)")
            self.nationality.setTitle("\(index)", forState: UIControlState.Normal)
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    
    @IBAction func termsAgreementClicked(sender: AnyObject)
    {
        
        forwardicon.hidden=false;
        getstartedButton.hidden=false
        checkbox.hidden=true
        self.view.layoutIfNeeded();
        scrollView.contentOffset = CGPointMake(0, 85);
    }
    @IBAction func getStartedButton(sender: AnyObject) {
        let email = self.emailField.text!
        let password = self.passwordField.text!
        // make sure the user entered both email & password
        if email != "" && password != "" {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion:  { (user, error) in
                if error == nil {
                    let uploadImage : UIImage = self.picture.image!
                    let base64String = self.imgToBase64(uploadImage)
                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
                    self.ref.child("users").child(user!.uid).setValue(["userFirstName": self.firstNameField.text!, "userLastName": self.lastNameField.text!, "userGender": self.genderLabel.text!, "userNationality": self.nationalityLabel.text!, "userDOB": self.dobLabel.text!, "email": email])
                    if self.imgTaken == false {
                        CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Please select the photo")
                        return
                    }
                    self.ref.child("users").child(user!.uid).child("image").setValue(base64String)
                    CommonUtils.sharedUtils.hideProgress()
                    let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                    self.navigationController?.pushViewController(mainViewController, animated: true)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        CommonUtils.sharedUtils.hideProgress()
                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    })
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Enter email & password!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Failed uploading profile image")
        }
    }
    
    @IBAction func maleButton(sender: AnyObject) {
        genderLabel.text = genderArray[0]
    }
    
    @IBAction func femaleButton(sender: AnyObject) {
        genderLabel.text = genderArray[1]
    }
    @IBAction func datePicker(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let strDate = dateFormatter.stringFromDate(datePickView.date)
        print(strDate)
        self.dobLabel.text = strDate
    }
    
}
