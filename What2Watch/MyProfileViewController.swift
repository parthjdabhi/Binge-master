//
//  MyProfileViewController.swift
//  What2Watch
//
//  Created by iParth on 8/16/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MyProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var btnMenu: UIButton?
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblDisplayName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imgs = ["ic_madel","ic_watch-video","ic_watchlist","ic_madel","ic_watchlist"]
    private var currentPage: Int = 1
    private var movieWatched:Array<[String:AnyObject]> = []
    
    private var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! PDCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .Horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    var ref = FIRDatabase.database().reference()
    var imagePickerController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgProfile.layoutIfNeeded()
        
        // Do any additional setup after loading the view.
        
        if let revealVC = self.revealViewController() {
            self.btnMenu?.addTarget(revealVC, action: #selector(revealVC.revealToggle(_:)), forControlEvents: .TouchUpInside)
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer());
            //self.navigationController?.navigationBar.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        self.collectionView.showsHorizontalScrollIndicator = false
        let layout = self.collectionView.collectionViewLayout as! PDCarouselFlowLayout
        layout.spacingMode = PDCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 100)
        layout.scrollDirection = .Horizontal
        
        imgProfile.layer.cornerRadius = max(imgProfile.frame.size.width, imgProfile.frame.size.height) / 2
        imgProfile.layer.borderWidth = 3
        imgProfile.layer.masksToBounds = true
        imgProfile.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).CGColor
        
        lblDisplayName.text = AppState.sharedInstance.displayName
        imgProfile.image = AppState.sharedInstance.myProfile ?? UIImage(named: "user.png")
        
        let imgTapGesture = UITapGestureRecognizer(target: self, action: #selector(MyProfileViewController.onTapProfilePic(_:)) )
        imgTapGesture.numberOfTouchesRequired = 1
        imgTapGesture.cancelsTouchesInView = true
        imgProfile.addGestureRecognizer(imgTapGesture)
        
        self.fetchMovieWatched()
    }
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if currentPage > 0 {
            let indexPath = NSIndexPath(forItem: currentPage, inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //    @IBAction func actionBack(sender: AnyObject) {
    //        self.navigationController?.popViewControllerAnimated(true)
    //    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    /**
     Custom functions
     */
    
    func onTapProfilePic(sender: UILongPressGestureRecognizer? = nil) {
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
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imgProfile.image = scaleImage(pickedImage, maxDimension: 300)
            AppState.sharedInstance.myProfile = imgProfile.image
            
            let base64String = self.imgToBase64(imgProfile.image!)
            let strProfile = base64String as String
            
            FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).setValue(strProfile, forKey: "image")
        }

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
    
    // MARK: - Card Collection Delegate & DataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Set Static values 5 here for test purpose
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SliderCollectionViewCell.identifier, forIndexPath: indexPath) as! SliderCollectionViewCell
        
        
        cell.image.layer.cornerRadius = max(cell.image.frame.size.width, cell.image.frame.size.height) / 2
        //cell.image.layer.borderWidth = 10
        cell.image.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).CGColor
        
        
        cell.selectedBackgroundView = nil
        
        switch indexPath.row {
        case 0:
            cell.image.image = UIImage(named: imgs[indexPath.row])
            cell.lblValue.text = "-"
            cell.lblTitle.text = "Title"
        case 1:
            cell.image.image = UIImage(named: "ic_watch-video")
            cell.lblValue.text = "\(self.movieWatched.count)"
            cell.lblTitle.text = "Watched Movies:"
        default:
            cell.image.image = UIImage(named: imgs[indexPath.row])
            cell.lblValue.text = "-"
            cell.lblTitle.text = "Title"
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        let character = items[indexPath.row]
        //        if currentPage != indexPath.row {
        //            //let indexPath = NSIndexPath(forItem: currentPage, inSection: 0)
        //            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        //            return
        //        }
        //        currentPage = indexPath.row
        
        //        let alert = UIAlertController(title: "Option \(indexPath.row+1)", message: nil, preferredStyle: .Alert)
        //        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        //        presentViewController(alert, animated: true, completion: nil)
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let movieWatchedVC:MovieWatchedVC = self.storyboard?.instantiateViewControllerWithIdentifier("MovieWatchedVC") as! MovieWatchedVC
        movieWatchedVC.movieWatched = self.movieWatched
        self.navigationController?.pushViewController(movieWatchedVC, animated: true)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! PDCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .Horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .Horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        print("currentPage = \(currentPage)")
    }
    
    func fetchMovieWatched() {
        ref.child("swiped").child(AppState.MyUserID()).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            CommonUtils.sharedUtils.hideProgress()
            self.movieWatched.removeAll()
            
            if snapshot.exists() {
                
                print(snapshot.childrenCount)
                //let swiped = snapshot.valueInExportFormat() as? NSDictionary
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    //print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                    if var dic = rest.value as? [String:AnyObject] {
                        dic["key"] = rest.key
                        self.movieWatched.append(dic)
                    }
                }
                
                if self.movieWatched.count > 0 {
                    self.collectionView.reloadData()
                }
            } else {
                // Not found any movie
            }
            
            }, withCancelBlock: { error in
                print(error.description)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
    }
}
