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
        self.profilePicture.hidden = true
        
        let uploadImage : UIImage = self.picture.image!
        let base64String = self.imgToBase64(uploadImage)
        TermsViewController.picture = base64String as String
        
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
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}
