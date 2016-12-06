//
//  MySlideMenuController.swift
//  What2Watch
//
//  Created by iParth on 8/3/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import SWRevealViewController
import Firebase

enum LeftMenu: Int {
    case Main = 0
    case Watchlist
    case What2watch
    case ImproveAccu
    case ShareWat2Watch
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

class MySlideMenuController : UIViewController {
    
    @IBOutlet weak var txtSearchbar: UITextField?
    @IBOutlet weak var btnSearch: UIButton?
    @IBOutlet weak var imgProfile: UIImageView?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblWachCount: UILabel?
    @IBOutlet weak var lblTimeWaste: UILabel?
    
    @IBOutlet weak var lblCount: UILabel?
    @IBOutlet weak var btnWatchlist: UIButton?
    @IBOutlet weak var btnWhat2Watch: UIButton?
    @IBOutlet weak var btnImproveAccu: UIButton?
    @IBOutlet weak var btnShareWhat2W: UIButton?
    @IBOutlet weak var btnHelp: UIButton?
    @IBOutlet weak var btnMainScreen: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    
    var ref = FIRDatabase.database().reference()
    private var movieSwiped:Array<[String:AnyObject]> = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        txtSearchbar?.setCornerRadious((txtSearchbar?.frame.size.height)!/2)
        txtSearchbar?.setLeftMargin()
        txtSearchbar?.setPlaceholderColor()
        
        let paddingView : UIView = UIView(frame: CGRectMake(0, 0, 16, 20))
        txtSearchbar?.leftView = paddingView
        txtSearchbar?.leftViewMode = UITextFieldViewMode.Always
        
        lblCount?.layer.cornerRadius = (lblCount?.frame.size.height)!/2
        lblCount?.layer.borderColor = lblCount!.textColor.CGColor
        lblCount?.layer.borderWidth = 1.0
        lblCount?.layer.masksToBounds = true
        
        imgProfile?.layer.cornerRadius = (imgProfile?.frame.width ?? 1) / 2
        imgProfile?.layer.borderWidth = 3
        imgProfile?.layer.masksToBounds = true
        imgProfile?.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).CGColor
        
        btnMainScreen.layer.borderWidth = 1
        btnMainScreen.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).CGColor
        
        btnLogout.layer.borderWidth = 1
        btnLogout.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).CGColor
        
        
        self.lblName?.text = "Hello"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MySlideMenuController.MyProfile))
        lblName?.addGestureRecognizer(tap)
        lblName?.userInteractionEnabled = true
        
        RefreshProfiledata()
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let watchlistVC = storyboard.instantiateViewControllerWithIdentifier("TermsViewController") as! TermsViewController
//        self.watchlistVC = UINavigationController(rootViewController: watchlistVC)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.imgProfile?.image = AppState.sharedInstance.myProfile ?? UIImage(named: "user.png")
        RefreshMovieCount()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    func MyProfile() {
        view.endEditing(true)
        self.actionMyProfile(nil)
    }
    
    func RefreshProfiledata()
    {
        //let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if snapshot.exists() {
                AppState.sharedInstance.currentUser = snapshot
                if let base64String = snapshot.value!["image"] as? String {
                    // decode image
                    // self.imgProfile?.image = CommonUtils.sharedUtils.decodeImage(base64String)
                    AppState.sharedInstance.myProfile = CommonUtils.sharedUtils.decodeImage(base64String)
                    self.imgProfile?.image = AppState.sharedInstance.myProfile ?? UIImage(named: "user.png")
                }
                let userFirstName = AppState.sharedInstance.currentUser?.value?["userFirstName"] as? String ?? ""
                let userLastName = AppState.sharedInstance.currentUser?.value?["userLastName"] as? String ?? ""
                AppState.sharedInstance.displayName = "\(userFirstName) \(userLastName)"
                self.lblName?.text =  AppState.sharedInstance.displayName
                
                AppState.sharedInstance.movieWatched = snapshot.value?["movieWatched"] as? String ?? "0"
                AppState.sharedInstance.timeWatched = snapshot.value?["timeWatched"] as? String ?? "0"
                AppState.sharedInstance.watchlistCount = snapshot.value?["watchlistCount"] as? String ?? "0"
                
                self.lblWachCount?.text = "Watched Movies : \(AppState.sharedInstance.movieWatched ?? "0")"
                self.lblTimeWaste?.text = "Wasted \(AppState.sharedInstance.timeWatched ?? "0") hours of my life on watching movies"
                
                self.lblCount?.text = AppState.sharedInstance.movieWatched
                if (AppState.sharedInstance.movieWatched ?? "0") == 0 {
                    //self.lblCount?.hidden = false
                } else {
                    //self.lblCount?.hidden = true
                }
            }
        })
    }
    
    func RefreshMovieCount()
    {
        ref.child("swiped").child(AppState.MyUserID()).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            CommonUtils.sharedUtils.hideProgress()
            self.movieSwiped.removeAll()
            
            if snapshot.exists() {
                
                print(snapshot.childrenCount)
                
                NSUserDefaults.standardUserDefaults().setObject(snapshot.childrenCount, forKey:"swipedMovieCount")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //let swiped = snapshot.valueInExportFormat() as? NSDictionary
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    //print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                    if var dic = rest.value as? [String:AnyObject] {
                        dic["key"] = rest.key
                        self.movieSwiped.append(dic)
                    }
                }
                
                if self.movieSwiped.count > 0 {
//                    let watchedMovies = self.movieSwiped.filter({
//                        if let subid = $0[status] as? String {
//                            return subid == status_dislike || subid  == status_like
//                        } else {
//                            return false
//                        }
//                    })
                    //print("watchedMovies : \(watchedMovies)")
                    
                    if self.movieSwiped.count > 0 {
                        self.lblWachCount?.text = "Watched Movies :  \(self.movieSwiped.count)"
                        self.lblTimeWaste?.text = "Wasted \(Int(Float(self.movieSwiped.count) * 2.5)) hours of life on watching movies"
                    } else {
                        self.lblTimeWaste?.text = "Wasted  0 hours of life on watching movies"
                    }
                    
                    let watchlistMovies = self.movieSwiped.filter({
                        if let subid = $0[status] as? String {
                            return subid == status_watchlist
                        } else {
                            return false
                        }
                    })
                    //print("watchlistMovies : \(watchlistMovies)")
                    
                    if watchlistMovies.count > 0 {
                        self.lblCount?.text = "\(watchlistMovies.count)"
                        self.lblCount?.hidden = false
                    } else {
                        // Not found any movie in watchlist
                        self.lblCount?.hidden = true
                    }
                    
                }
            } else {
                // Not found any movie
            }
            
            }, withCancelBlock: { error in
                print(error.description)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
    }
    
//    func RefreshWatchllistCount() {
//        ref.child("swiped").child(AppState.MyUserID())
//            .queryOrderedByChild("status")
//            .queryEqualToValue("Watchlist")
//            .observeSingleEventOfType(.Value, withBlock: { snapshot in
//                if snapshot.exists() && snapshot.childrenCount > 0 {
//                    print(snapshot.childrenCount)
//                    self.lblCount?.text = "\(snapshot.childrenCount)"
//                    self.lblCount?.hidden = false
//                } else {
//                    // Not found any movie
//                    self.lblCount?.hidden = true
//                }
//            }, withCancelBlock: { error in
//                print(error.description)
//                MBProgressHUD.hideHUDForView(self.view, animated: true)
//                self.lblCount?.hidden = true
//            })
//    }
    
    @IBAction func actionMainScreen(sender: AnyObject) {
        self.performSegueWithIdentifier("segueMainScreen", sender: self)
    }
    
    @IBAction func actionMyProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("segueMyProfile", sender: self)
    }
    
    @IBAction func actionLogout(sender: AnyObject) {
        AppState.Logout()
        try! FIRAuth.auth()?.signOut()
        //self.performSegueWithIdentifier("segueLogin", sender: self)
    }
    
    @IBAction func actionWatchlist(sender: AnyObject) {
        self.performSegueWithIdentifier("segueWatchlist", sender: self)
    }
    
    @IBAction func actionWhat2watch(sender: AnyObject) {
        self.performSegueWithIdentifier("segueWhat2Watch", sender: self)
    }
    
    @IBAction func actionImproveAccuracy(sender: AnyObject) {
        self.performSegueWithIdentifier("segueMainScreen", sender: self)
    }
    
    @IBAction func actionShareWhat2Watch(sender: AnyObject) {
        //self.performSegueWithIdentifier("segueWhat2Watch", sender: self)
    }
    
    @IBAction func actionHelp(sender: AnyObject) {
        self.performSegueWithIdentifier("segueHelp", sender: self)
    }
}

