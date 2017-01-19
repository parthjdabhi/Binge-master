//
//  CommonUtils.swift
//  What2Watch
//
//  Created by Dustin Allen 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

import Firebase
import FirebaseStorage



class CommonUtils: NSObject {
    static let sharedUtils = CommonUtils()
    var progressView : MBProgressHUD = MBProgressHUD.init()
    
    // show alert view
    func showAlert(controller: UIViewController, title: String, message: String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        controller.presentViewController(ac, animated: true){}
    }
    
    // show progress view
    func showProgress(view : UIView, label : String) {
        progressView = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressView.labelText = label
    }
    
    // hide progress view
    func hideProgress(){
        progressView.removeFromSuperview()
        progressView.hide(true)
    }
    
    func decodeImage(base64String : String) -> UIImage {
        let decodedData = NSData(base64EncodedString: base64String, options:  NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let image = UIImage(data: decodedData!)
        return image!
    }
}

//FireBase Storage
let storage = FIRStorage.storage()
let storageRef = storage.reference()

func saveImage(imgData:NSData, onCompletion:(downloadURL:String,imagePath:String)->Void)
{
    //CommonUtils.sharedUtils.showProgress(self.view, label: "Saving Profile..")
    //let imgData: NSData = UIImageJPEGRepresentation(image, 0.7)!
    let imgPath = "images/\(NSDate().timeIntervalSince1970).jpg"
    // Create a reference to the file you want to upload
    let imagesRef = storageRef.child(imgPath)
    
    let uploadTask = imagesRef.putData(imgData, metadata: nil) { metadata, error in
        if (error != nil) {
            // Uh-oh, an error occurred!
            print(error)
            CommonUtils.sharedUtils.hideProgress()
        } else {
            print(metadata)
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata!.downloadURL()?.absoluteString ?? ""
            print(downloadURL,imgPath)
            onCompletion(downloadURL: downloadURL,imagePath: imgPath)
        }
    }
    
    //        uploadTask.observeStatus(.Progress) { snapshot in
    //            // Upload reported progress
    //            if let progress = snapshot.progress {
    //                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
    //                print(percentComplete)
    //            }
    //        }
}


/*
FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
    if let user = user {
        // User is signed in.
    } else {
        // No user is signed in.
    }
}
*/