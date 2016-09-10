//
//  ProfilePictureViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/28/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class ProfilePictureViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var profilePicture: UIButton!
    @IBOutlet var xIcon: UIImageView!
    @IBOutlet var picture: UIImageView!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    var imagePickerController: UIImagePickerController!
    var imgTaken = false
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        picture.layer.masksToBounds = false
        picture.layer.cornerRadius = picture.frame.height/2
        picture.clipsToBounds = true
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
    
    @IBAction func pictureButton(sender: AnyObject) {
        // 1
        view.endEditing(true)
        
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .ActionSheet)

        // 3
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .Default) { (alert) -> Void in
                                                self.imagePickerController = UIImagePickerController()
                                                self.imagePickerController.delegate = self
                                                self.imagePickerController.sourceType = .Camera
                                                self.presentViewController(self.imagePickerController,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
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
        
        
//        let uploadImage : UIImage = self.picture.image!
//        let base64String = self.imgToBase64(uploadImage)
//        TermsViewController.picture = base64String as String
        
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
        
        self.xIcon.hidden = true
        //self.profilePicture.hidden = true
        self.profilePicture.setImage(nil, forState: .Normal)
        
        let uploadImage : UIImage = self.picture.image!
        let base64String = uploadImage.imgToBase64()
        TermsViewController.picture = base64String as String
        
        self.imgTaken = true
        dismissViewControllerAnimated(true) {
            self.goNextSelectorClosure?()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    @IBAction func backButton(sender: AnyObject) {
        self.goBackSelectorClosure?()
        //self.dismissViewControllerAnimated(true, completion: nil);
    }
}
