//
//  RecomendationVC.swift
//  What2Watch
//
//  Created by iParth on 9/1/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import SWRevealViewController

import SDWebImage
import SWRevealViewController
import UIActivityIndicator_for_SDWebImage

class RecomendationVC: UIViewController {

    @IBOutlet var btnMenu: UIButton?
    @IBOutlet var lblMsgCentered: UILabel?
    @IBOutlet var imgPoster: UIImageView?
    
    //50% of my like should be match with other user to give recommendation
    let MyLikePer:Float = 4
    var MinLikeMovieToMatch = 1 //50% of my total Like
    
    var movieSwiped:Array<[String:AnyObject]> = []
    
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblMsgCentered?.text = "Finding best recommendation for you"
        
        if let revealVC = self.revealViewController() {
            self.btnMenu?.addTarget(revealVC, action: #selector(revealVC.revealToggle(_:)), forControlEvents: .TouchUpInside)
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer());
            //            self.navigationController?.navigationBar.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading..")
//        ref.child("swiped").child(AppState.MyUserID()).observeSingleEventOfType(.Value, withBlock: { snapshot in
//            
//            CommonUtils.sharedUtils.hideProgress()
//            self.movieSwiped.removeAll()
//            AppState.sharedInstance.My_Like_top2000 = []
//            
//            if snapshot.exists() {
//                
//                print(snapshot.childrenCount)
//                //let swiped = snapshot.valueInExportFormat() as? NSDictionary
//                let enumerator = snapshot.children
//                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
//                    //print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
//                    if var dic = rest.value as? [String:AnyObject] {
//                        dic["key"] = rest.key
//                        self.movieSwiped.append(dic)
//                    }
//                }
//                
//                if self.movieSwiped.count > 0 {
//                    let My_Like_top2000 = self.movieSwiped.filter({
//                        if let subid = $0[status] as? String {
//                            return subid == status_like
//                        } else {
//                            return false
//                        }
//                    })
//                    
//                    AppState.sharedInstance.My_Like_top2000 = My_Like_top2000
//                    print("My Liked Movie List : \(AppState.sharedInstance.My_Like_top2000)")
//                    
//                    if My_Like_top2000.count > 0 {
//                        self.MinLikeMovieToMatch = Int(floor(Double(My_Like_top2000.count/2)))
//                        print("My Liked Movies count :  \(My_Like_top2000.count) Min Like Movie To Match : \(self.MinLikeMovieToMatch) \n\n\n\n")
//                    } else {
//                        // Not Have enough Detail for recommendation
//                    }
//                }
//            } else {
//                // Not found any movie
//                // Not Have enough Detail for recommendation
//            }
//            
//            }, withCancelBlock: { error in
//                print(error.description)
//                MBProgressHUD.hideHUDForView(self.view, animated: true)
//        })
        
        let dateStart = NSDate()
        ref.child("swiped").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            CommonUtils.sharedUtils.hideProgress()
            self.movieSwiped.removeAll()
            AppState.sharedInstance.My_Like_MovieID_top2000 = []
            AppState.sharedInstance.My_Like_top2000 = []
            AppState.sharedInstance.OUser_Like_top2000 = []
            AppState.sharedInstance.My_Like_Recom_MovieID_top2000 = []
            
            print("Operation Time : \(dateStart) -- \(NSDate())  ==--> \(NSDate().timeIntervalSinceDate(dateStart))")
            
            if snapshot.exists()
            {
                print(snapshot.childrenCount)
                
                let swiped = snapshot.valueInExportFormat() as? NSDictionary
                print(" swiped : \(swiped)")
                //let AllUserSwipeMovies = swiped?[AppState.MyUserID()] as? [String:AnyObject]
                let allUserKey = swiped?.allKeys as? [String] ?? []  //mySwipeMovies?.keys.sort()
                print(allUserKey)
                
//                let MySwipeDict = swiped?.dictionaryWithValuesForKeys([AppState.MyUserID()])
//                let keys: NSArray = swiped?.allKeys ?? []
//                var filteredKeys: [String] = keys.filteredArrayUsingPredicate(NSPredicate(format: "SELF NOT CONTAINS[cd] %@", AppState.MyUserID())) as! [String]
                self.movieSwiped.removeAll()
                
                for userKey in allUserKey {
                    print("User ID  =>>  \(userKey)")
                    if userKey == AppState.MyUserID() {
                        if let MySwipe = swiped![userKey] as? NSDictionary {
                            let allMovieKey = MySwipe.allKeys as? [String] ?? []
                            for key in allMovieKey {
                                if let movieSwiped = MySwipe[key] as? [String:AnyObject] {
                                    // All Movie Liked by me
                                    if let entryStatus = movieSwiped[status] as? String
                                        where entryStatus == status_like
                                    {
                                        AppState.sharedInstance.My_Like_MovieID_top2000.append(movieSwiped["imdbID"] as? String ?? "")
                                        self.movieSwiped.append(movieSwiped)
                                    }
                                }
                            }
                        }
                        print("self.movieSwiped || My_Like_top2000 : \(self.movieSwiped.count)")
                        AppState.sharedInstance.My_Like_top2000 = self.movieSwiped
                    } else {
                        var ThisUserSwipedLikeEntry:Array<[String:AnyObject]> = []
                        if let ThisUserSwipes = swiped![userKey] as? NSDictionary {
                            let allMovieKey = ThisUserSwipes.allKeys as? [String] ?? []
                            for key in allMovieKey {
                                if let movieSwiped = ThisUserSwipes[key] as? [String:AnyObject] {
                                    // All Movie Liked by me
                                    if let entryStatus = movieSwiped[status] as? String
                                        where entryStatus == status_like
                                    {
                                        ThisUserSwipedLikeEntry.append(movieSwiped)
                                    }
                                }
                            }
                        }
                        
                        print("ThisUserSwipedLikeEntry : \(ThisUserSwipedLikeEntry.count)")
                        if ThisUserSwipedLikeEntry.count > 0 {
                            AppState.sharedInstance.OUser_Like_top2000.append(ThisUserSwipedLikeEntry)
                        }
                    }
                }
                
                print("My Liked Movie List : \(AppState.sharedInstance.My_Like_MovieID_top2000)")
                
                if AppState.sharedInstance.My_Like_top2000.count > 0
                    && AppState.sharedInstance.My_Like_MovieID_top2000.count > 0
                    && AppState.sharedInstance.accu_All_top2000?.count > 0
                {
                    //print("My Liked Movie List : \(AppState.sharedInstance.My_Like_top2000)")
                    if AppState.sharedInstance.My_Like_top2000.count > 0 {
                        self.MinLikeMovieToMatch = Int(ceil(Float(AppState.sharedInstance.My_Like_top2000.count) * self.MyLikePer / 100.0))
                        print("\n\n\n\n My Liked Movies count :  \(AppState.sharedInstance.My_Like_top2000.count) & Require Minimum Like Movie To Match is : \(self.MinLikeMovieToMatch) \n\n\n\n")
                        
                        //Compare ALL User with more than 50% Like Matched with me
                        
                        print("Compare \(AppState.sharedInstance.OUser_Like_top2000.count) Users Like Entry count")
                        
                        for ThisUserSwipedLikeEntry in AppState.sharedInstance.OUser_Like_top2000
                        {
                            print("ThisUserSwipedLikeEntry : \(ThisUserSwipedLikeEntry.count)")
                            
                            if ThisUserSwipedLikeEntry.count >= self.MinLikeMovieToMatch
                            {
                                let Filtered = ThisUserSwipedLikeEntry.filter({ (SwipeEntry) -> Bool in
                                    if let imdbID = SwipeEntry["imdbID"] as? String
                                        where AppState.sharedInstance.My_Like_MovieID_top2000.contains(imdbID) {
                                        return true
                                    }
                                    return false
                                })
                                print("Matched \(Filtered.count)")
                                
                                if Filtered.count >= self.MinLikeMovieToMatch {
                                    print("We can get recommondation from this list \(ThisUserSwipedLikeEntry)")
                                    
                                    let RecommendationFiltered = ThisUserSwipedLikeEntry.filter({ (SwipeEntry) -> Bool in
                                        if let imdbID = SwipeEntry["imdbID"] as? String
                                            where !(AppState.sharedInstance.My_Like_MovieID_top2000.contains(imdbID))
                                            && !(AppState.sharedInstance.My_Like_Recom_MovieID_top2000.contains(imdbID))
                                        {
                                            AppState.sharedInstance.My_Like_Recom_MovieID_top2000.append(imdbID)
                                            return true
                                        }
                                        return false
                                    })
                                    
                                    print("Recommendation Filtered \(RecommendationFiltered.count)")
                                }
                            }
                        }
                        
                        //shuffel position in array and show random movie as recommendation
                        AppState.sharedInstance.My_Like_Recom_MovieID_top2000.shuffleInPlace()
                        
                        if AppState.sharedInstance.My_Like_Recom_MovieID_top2000.count > 0 {
                            print("\n\nGot \(AppState.sharedInstance.My_Like_Recom_MovieID_top2000) Recommendation movie\n\n")
                            print(AppState.sharedInstance.My_Like_Recom_MovieID_top2000)
                            
                            //Black&WhitePeople
                            let imdbID = AppState.sharedInstance.My_Like_Recom_MovieID_top2000[0]
                            let posterURL = "http://img.omdbapi.com/?i=\(imdbID)&apikey=57288a3b&h=1000"
                            let posterNSURL = NSURL(string: "\(posterURL)")
                            
                            print(" \(index) Movie: \(imdbID) , Image: \(posterURL)")
                            self.imgPoster?.setImageWithURL(posterNSURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.AllowInvalidSSLCertificates, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
                        } else {
                            
                            let alertController = UIAlertController(title: "Swipe More", message: "You haven't swiped enough movies to generate a recommendation.", preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                
                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            alertController.addAction(okAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                    } else {
                        
                        let alertController = UIAlertController(title: "Swipe More", message: "You haven't swiped enough movies to generate a recommendation.", preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                            
                            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                
                let alertController = UIAlertController(title: "Swipe More", message: "You haven't swiped enough movies to generate a recommendation.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                    
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            }, withCancelBlock: { error in
                print(error.description)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
