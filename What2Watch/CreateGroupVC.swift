//
//  CreateGroupVC.swift
//  What2Watch
//
//  Created by iParth on 10/25/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CreateGroupVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - VC Outlets
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var imgGroup: UIImageView!
    @IBOutlet var btnaddMember: UIButton!
    @IBOutlet var lblMembersCount: UILabel!
    @IBOutlet var btnCreateGroup: UIButton!
    @IBOutlet weak var txtGroupName: UITextField!
    
    // MARK: - VC Properties
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    var imagePickerController: UIImagePickerController!
    var imgTaken = false
    
    var searchResultController:searchController!
    var searchString:String = ""
    var myTimer:NSTimer = NSTimer()
    
    // MARK: - VC Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        selectedUsers.removeAll()
        
        searchResultController = searchController()
        searchResultController.delegate = self
        
        txtGroupName.setCornerRadious()
        txtGroupName.setLeftMargin()
        txtGroupName.setBorder(1, color: UIColor.darkGrayColor())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - VC Actions
    
    @IBAction func actionGoToBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func actionSelectGroupImage(sender: AnyObject) {
        TakePicture()
    }
    
    @IBAction func actionAddMember(sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        //searchController.searchBar.text = self.searchBar.text
        //searchController.searchBar.showsSearchResultsButton = true
        self.presentViewController(searchController, animated: true, completion: nil)
    }
    
    @IBAction func actionCreateGroup(sender: AnyObject) {
        
        if imgTaken == false {
            SVProgressHUD.showInfoWithStatus("Select group Image!")
        } else if txtGroupName.text == "" {
            SVProgressHUD.showInfoWithStatus("Need your group name!")
        } else if selectedUsers.count == 0 {
            SVProgressHUD.showInfoWithStatus("Add more group member!")
        }
        else {
            var data:Dictionary<String,AnyObject> = ["createdBy":myUserID ?? "","groupName":txtGroupName.text ?? ""]
            var Members:[String] = []
            for user in selectedUsers {
                if let key = user["key"] as? String {
                    Members.append(key)
                }
            }
            data["members"] = Members
            data["createdAt"] = "\(NSDate().timeIntervalSince1970)"
            
            //Saving Image
            //let base64String = (imgGroup.image!).imgToBase64()
            //let image = CommonUtils.sharedUtils.decodeImage(base64String)
            let imgData: NSData = UIImageJPEGRepresentation(imgGroup.image!, 0.8)!
            //CommonUtils.sharedUtils.decodeImage(userPhoto)
            saveImage(imgData,
                      onCompletion: { (downloadURL, imagePath) in
                        print("downloadURL : ",downloadURL)
                        print("imagePath : ",imagePath)
                        data["imageUrl"] = downloadURL
                        self.ref.child("groups").childByAutoId().updateChildValues(data)
                        SVProgressHUD.showSuccessWithStatus("Group created successfully")
                        self.navigationController?.popViewControllerAnimated(true)
                        //let dictData = ["imageUrl": downloadURL, "imagePath": imagePath]
                        //FIRDatabase.database().reference().child("group").child(myUserID ?? "").updateChildValues(dictData)
                        //FIRDatabase.database().reference().child("group").child(myUserID ?? "").child("image").removeValue()
                        //CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Picture updated succcessfully!")
            })
            
        }
        
        
    }

    // MARK: - VC Methods
    
    func TakePicture()
    {
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
                                                self.imagePickerController.allowsEditing = true
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
                                            self.imagePickerController.allowsEditing = true
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
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imgGroup.contentMode = .ScaleAspectFit
            imgGroup.image = scaleImage(pickedImage, maxDimension: 300)
        } else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgGroup.contentMode = .ScaleAspectFit
            imgGroup.image = scaleImage(pickedImage, maxDimension: 300)
        }
        
        //let uploadImage : UIImage = self.imgGroup.image!
        //let base64String = uploadImage.imgToBase64()
        
        self.imgTaken = true
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // Perform the search.
    private func doSearch(showLoader:Bool = true)
    {
        if showLoader == true {
            //SVProgressHUD.showWithStatus("Searching..")
        }
//        barSearchResults = bars.filter({ (bar) -> Bool in
//            if let name = bar["venueName"] as? String {
//                return (name.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil) ? true : false
//            }
//            return false
//        })
//        print(barSearchResults.count)
//        searchResultController.reloadDataWithArray(barSearchResults)
        
//        if isRefreshingData == true {
//            return
//        }
        
        //isRefreshingData = true
        let myGroup = dispatch_group_create()
        
        dispatch_group_enter(myGroup)
        
    
        SVProgressHUD.showWithStatus("Loading..")
        FIRDatabase.database().reference().child("users").queryOrderedByChild("userFirstName").queryStartingAtValue(searchString).observeEventType(.Value, withBlock: { snapshot in
            
            filteredUser.removeAll()
            
            print("\(NSDate().timeIntervalSince1970)")
            //self.tblGroups.reloadData()
            for child in snapshot.children {
                
                var placeDict = Dictionary<String,AnyObject>()
                let childDict = child.valueInExportFormat() as! NSDictionary
                //print(childDict)
                
                let snap = child as! FIRDataSnapshot
                //let jsonDic = NSJSONSerialization.JSONObjectWithData(childDict, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<String, AnyObject>;
                for key : AnyObject in childDict.allKeys {
                    let stringKey = key as! String
                    if let keyValue = childDict.valueForKey(stringKey) as? String {
                        placeDict[stringKey] = keyValue
                    } else if let keyValue = childDict.valueForKey(stringKey) as? Double {
                        placeDict[stringKey] = "\(keyValue)"
                    }
                    else if let keyValue = childDict.valueForKey(stringKey) as? Dictionary<String,AnyObject> {
                        placeDict[stringKey] = keyValue
                    }
                    else if let keyValue = childDict.valueForKey(stringKey) as? NSDictionary {
                        placeDict[stringKey] = keyValue
                    }
                    
                }
                placeDict["key"] = child.key
                
                filteredUser.append(placeDict)
                //print(placeDict)
            }
            dispatch_group_leave(myGroup)
        })
        dispatch_group_notify(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                // update UI
                SVProgressHUD.dismiss()
                //self.isRefreshingData = false
                
                print(filteredUser.count)
                self.searchResultController.reloadDataWithArray(filteredUser)
            }
        }
    }
}

extension CreateGroupVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        //        let searchController = UISearchController(searchResultsController: searchResultController)
        //        searchController.searchBar.delegate = self
        //        searchController.searchBar.text = self.searchBar.text
        //        //searchController.searchBar.showsSearchResultsButton = true
        //        self.presentViewController(searchController, animated: true, completion: nil)
        //return false;
        searchBar.setShowsCancelButton(true, animated: true)
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        if let searchStr = searchBar.text {
            print(searchStr)
            searchString = searchStr
            searchBar.resignFirstResponder()
            doSearch()
            searchResultController.dismissViewControllerAnimated(true, completion: nil)
        }
        //searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        print("Bookmark")
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchString = ""
        searchBar.resignFirstResponder()
        //doSearchSuggestion()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchString = searchBar.text!
        searchBar.resignFirstResponder()
        //doSearchSuggestion()
        //self.searchBar.text = searchString
        doSearch()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        //myTimer.invalidate()
        searchString = searchText
        //doSearch()
        myTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CreateGroupVC.searchInTime), userInfo: nil, repeats: false)
    }
    
    func searchInTime() {
        doSearch()
    }
}

extension CreateGroupVC: searchDelegate {
    
    func onItemSelected(bar: Dictionary<String,AnyObject>) {
        selectedUsers.append(bar)
        self.lblMembersCount.text = "Member : \(selectedUsers.count)"
//        let index = filteredBars.indexOf {
//            //($0["key"] as? String != nil && bar["key"] as? String != nil)
//            if let key1 = $0["key"] as? String, key2 = bar["key"] as? String where key1 == key2 {
//                return true
//            }
//            return false
//        }
        
    }
}

