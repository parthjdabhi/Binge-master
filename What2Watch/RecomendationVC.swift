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
import UIActivityIndicator_for_SDWebImage
import Alamofire

import Koloda
import pop

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.05


class RecomendationVC: UIViewController {
    
    
    @IBOutlet var btnMenu: UIButton?
    @IBOutlet var lblMsgCentered: UILabel?
    @IBOutlet weak var cardHolderView: CustomKolodaView!
    
    //Instriction View
    @IBOutlet var vInstruction: UIView!
    @IBOutlet var imgInstruction: UIImageView!
    @IBOutlet var imgPoster: UIImageView?
    @IBOutlet var lblMovieTitle: UILabel!
    @IBOutlet var lblGenere: UILabel!
    @IBOutlet var lblYear: UILabel!
    @IBOutlet var lblDirector: UILabel!
    @IBOutlet var lblLikes: UILabel!
    
    //50% of my like should be match with other user to give recommendation
    let MyLikePer:Float = 50
    var MinLikeMovieToMatch = 50 //50% of my total Like
    
    var movieSwiped:Array<[String:AnyObject]> = []
    var movies:Array<[String:AnyObject]> = []
    var accu_movies:Array<[String:AnyObject]> = []
    var lastSwipedMovie:String?
    
    var ref = FIRDatabase.database().reference()
    
    //Filter Reco Movie
    var Rec_movies_seen:Array<String> = []
    var Rec_movies_seen1:Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblMsgCentered?.text = "Finding best recommendation for you"
        
        cardHolderView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        cardHolderView.countOfVisibleCards = kolodaCountOfVisibleCards
        cardHolderView.delegate = self
        cardHolderView.dataSource = self
        cardHolderView.animator = BackgroundKolodaAnimatorTest(koloda: cardHolderView)
        cardHolderView.backgroundColor = UIColor.whiteColor()
        
        vInstruction.alpha = 0
        self.imgPoster?.setCornerRadious((self.imgPoster?.frame.width ?? 1)/2)
        
        if let revealVC = self.revealViewController() {
            self.btnMenu?.addTarget(revealVC, action: #selector(revealVC.revealToggle(_:)), forControlEvents: .TouchUpInside)
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer());
            //            self.navigationController?.navigationBar.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(RecomendationVC.imageTapped(_:)))
        vInstruction.userInteractionEnabled = true
        vInstruction.addGestureRecognizer(tapGestureRecognizer)
        
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
                        
                        // shuffel position in array and show random movie as recommendation
                        AppState.sharedInstance.My_Like_Recom_MovieID_top2000.shuffleInPlace()
                        
                        print("AppState.sharedInstance.My_Like_Recom_MovieID_top2000",AppState.sharedInstance.My_Like_Recom_MovieID_top2000)
                        
                        //var swipedRecomm:Array<String> = []
                        self.Rec_movies_seen = []
                        
                        // Previously seen Reco Movies __ after filter attach to last
                        if let Rec_movies_seen_saved = NSUserDefaults.standardUserDefaults().objectForKey("Rec_movies_seen") as? [String] {
                            self.Rec_movies_seen = Rec_movies_seen_saved
                            print("Rec_movies_seen_saved founds - Count \(Rec_movies_seen_saved.count) ---- \(Rec_movies_seen_saved)")
                            
                            //Rec_movies_seen.append(AppState.sharedInstance.My_Like_Recom_MovieID_top2000[forIndex])
                            //NSUserDefaults.standardUserDefaults().setObject(Rec_movies_seen_saved, forKey: "Rec_movies_seen")
                        }
                        
                        for swipedMovie in self.Rec_movies_seen {
                            if AppState.sharedInstance.My_Like_Recom_MovieID_top2000.contains(swipedMovie) {
                                if let indexToRemove = AppState.sharedInstance.My_Like_Recom_MovieID_top2000.indexOf(swipedMovie) {
                                    AppState.sharedInstance.My_Like_Recom_MovieID_top2000.removeAtIndex(indexToRemove)
                                    AppState.sharedInstance.My_Like_Recom_MovieID_top2000.append(swipedMovie)
                                }
                            }
                        }
                        print("AppState.sharedInstance.My_Like_Recom_MovieID_top2000 swipedMovie",AppState.sharedInstance.My_Like_Recom_MovieID_top2000)
                        
                        if AppState.sharedInstance.My_Like_Recom_MovieID_top2000.count > 0 {
                            print("\n\nGot \(AppState.sharedInstance.My_Like_Recom_MovieID_top2000) Recommendation movie\n\n")
                            print(AppState.sharedInstance.My_Like_Recom_MovieID_top2000)
                            
                            self.ShowMovieDetail(AppState.sharedInstance.My_Like_Recom_MovieID_top2000[0])
                            self.cardHolderView.reloadData()
                            
                        } else {
                            self.lblMsgCentered?.text = "No Recommendations :("
                            let alertController = UIAlertController(title: "Swipe More!", message: "Give our algorithms a little more data to work with, head back to the improve accuracy page and keep rating movies!", preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                
                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            alertController.addAction(okAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    } else {
                        self.lblMsgCentered?.text = "No Recommendations :("
                        let alertController = UIAlertController(title: "Swipe More!", message: "Give our algorithms a little more data to work with, head back to the improve accuracy page and keep rating movies!", preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                            
                            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                self.lblMsgCentered?.text = "No Recommendations :("
                let alertController = UIAlertController(title: "Swipe More!", message: "Give our algorithms a little more data to work with, head back to the improve accuracy page and keep rating movies!", preferredStyle: UIAlertControllerStyle.Alert)
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
    

    func imageTapped(img: AnyObject)
    {
        //self.navigationController?.popViewControllerAnimated(true)
        //Hide Card Instruction and show swippable card view.
        
//        UIView.animateWithDuration(0.5, animations: {
//            self.vInstruction.alpha = 0
//        })
        
        UIView.animateWithDuration(0.3, animations: {
            self.vInstruction.alpha = 0
        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func ShowMovieDetail(imdbID:String)
    {
        
        //Black&WhitePeople
        let imdbID = AppState.sharedInstance.My_Like_Recom_MovieID_top2000[0]
        let posterURL = "http://img.omdbapi.com/?i=\(imdbID)&apikey=57288a3b&h=1000"
        let posterNSURL = NSURL(string: "\(posterURL)")
        
        print(" \(index) Movie: \(imdbID) , Image: \(posterURL)")
        
        self.imgPoster?.setImageWithURL(posterNSURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.AllowInvalidSSLCertificates, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        
        UIView.animateWithDuration(0.3, animations: {
            self.vInstruction.alpha = 1
        })
        
        self.lblYear.text = "-"
        self.lblMovieTitle.text = "-"
        self.lblDirector.text = "-"
        self.lblLikes.text = "-"
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Please wait..")
        let movieFullDetailURL = "http://www.omdbapi.com/"  //http:// www.omdbapi.com/?i=(*imdbID*)&plot=short&r=json
        Alamofire.request(.GET, movieFullDetailURL, parameters: ["i": imdbID, "apikey":"57288a3b", "plot":"short", "r":"json"])
            .responseJSON { response in
                
                debugPrint(response)
                CommonUtils.sharedUtils.hideProgress()
                
                if let JSON = response.result.value as? [String:String] {
                    print("Success with JSON: \(JSON)")
                    
                    if let Year = JSON["Year"] {
                        self.lblYear.text = "\(Year)"
                        self.lblYear.addTextSpacing(2)
                    }
                    if let Title = JSON["Title"] {
                        self.lblMovieTitle.text = "\(Title)"
                    }
                    if let Director = JSON["Director"] {
                        self.lblDirector.text = "Directed by \(Director)"
                    }
                    if let Likes = JSON["imdbVotes"] {
                        self.lblLikes.text = "\(Likes) Likes"
                    }
                }
        }
    }
    
    func SaveSwipeEntry(forIndex: Int,Status: String)
    {
        if forIndex >= AppState.sharedInstance.My_Like_Recom_MovieID_top2000.count {
            return
        }
        
        //Saved Seen recommendation in userDefaults
        if let Rec_movies_seen_saved = NSUserDefaults.standardUserDefaults().objectForKey("Rec_movies_seen") as? [String] {
            Rec_movies_seen = Rec_movies_seen_saved
            Rec_movies_seen.append(AppState.sharedInstance.My_Like_Recom_MovieID_top2000[forIndex])
            NSUserDefaults.standardUserDefaults().setObject(Rec_movies_seen, forKey: "Rec_movies_seen")
        } else {
            Rec_movies_seen.append(AppState.sharedInstance.My_Like_Recom_MovieID_top2000[forIndex])
            NSUserDefaults.standardUserDefaults().setObject(Rec_movies_seen, forKey: "Rec_movies_seen")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
        print("Rec_movies_seen -- ", Rec_movies_seen)
        
//        var Movie =  AppState.sharedInstance.My_Like_Recom_MovieID_top2000[forIndex]
//        Movie["status"] = Status
//        
//        FIRDatabase.database().reference().child("swiped").child(FIRAuth.auth()?.currentUser?.uid ?? "").child(Movie["key"] as? String ?? "").setValue(Movie)
//        
//        let imdbID = Movie["imdbID"] as? String ?? ""
//        FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("lastSwiped").child("top2000").setValue(imdbID)
//        
//        if let genre = movies[forIndex]["genre"] as? String
//            where AppState.sharedInstance.accu_All_top2000 != nil
//        {
//            if var value = AppState.sharedInstance.accu_All_top2000![genre] {
//                value = value + 1
//                AppState.sharedInstance.accu_All_top2000![genre] = value
//            } else {
//                AppState.sharedInstance.accu_All_top2000![genre] = 1
//            }
//            
//            if var value = AppState.sharedInstance.accu_All_top2000!["Total"] {
//                value = value + 1
//                AppState.sharedInstance.accu_All_top2000!["Total"] = value
//            } else {
//                AppState.sharedInstance.accu_All_top2000!["Total"] = 1
//            }
//            
//            print(" accu_All_top2000 \(AppState.sharedInstance.accu_All_top2000) ")
//            FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child("all").setValue(AppState.sharedInstance.accu_All_top2000!)
//            
//            if Status == status_like
//                && AppState.sharedInstance.accu_Like_top2000 != nil
//            {
//                if var value = AppState.sharedInstance.accu_Like_top2000![genre] {
//                    value = value + 1
//                    AppState.sharedInstance.accu_Like_top2000![genre] = value
//                } else {
//                    AppState.sharedInstance.accu_Like_top2000![genre] = 1
//                }
//                
//                if var value = AppState.sharedInstance.accu_Like_top2000!["Total"] {
//                    value = value + 1
//                    AppState.sharedInstance.accu_Like_top2000!["Total"] = value
//                } else {
//                    AppState.sharedInstance.accu_Like_top2000!["Total"] = 1
//                }
//                
//                print(" accu_Like_top2000 \(AppState.sharedInstance.accu_Like_top2000) ")
//                FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child(status_like).setValue(AppState.sharedInstance.accu_Like_top2000!)
//            }
//            else if Status == status_dislike
//                && AppState.sharedInstance.accu_Dislike_top2000 != nil
//            {
//                if var value = AppState.sharedInstance.accu_Dislike_top2000![genre] {
//                    value = value + 1
//                    AppState.sharedInstance.accu_Dislike_top2000![genre] = value
//                } else {
//                    AppState.sharedInstance.accu_Dislike_top2000![genre] = 1
//                }
//                
//                if var value = AppState.sharedInstance.accu_Dislike_top2000!["Total"] {
//                    value = value + 1
//                    AppState.sharedInstance.accu_Dislike_top2000!["Total"] = value
//                } else {
//                    AppState.sharedInstance.accu_Dislike_top2000!["Total"] = 1
//                }
//                
//                print(" accu_Dislike_top2000 \(AppState.sharedInstance.accu_Dislike_top2000) ")
//                FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child(status_dislike).setValue(AppState.sharedInstance.accu_Dislike_top2000!)
//            }
//            else if Status == status_watchlist
//                && AppState.sharedInstance.accu_Watched_top2000 != nil
//            {
//                if var value = AppState.sharedInstance.accu_Watched_top2000![genre] {
//                    value = value + 1
//                    AppState.sharedInstance.accu_Watched_top2000![genre] = value
//                } else {
//                    AppState.sharedInstance.accu_Watched_top2000![genre] = 1
//                }
//                
//                if var value = AppState.sharedInstance.accu_Watched_top2000!["Total"] {
//                    value = value + 1
//                    AppState.sharedInstance.accu_Watched_top2000!["Total"] = value
//                } else {
//                    AppState.sharedInstance.accu_Watched_top2000!["Total"] = 1
//                }
//                
//                print(" accu_Watched_top2000 \(AppState.sharedInstance.accu_Watched_top2000) ")
//                FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child(status_watchlist).setValue(AppState.sharedInstance.accu_Watched_top2000!)
//            }
//            else if Status == status_haventWatched
//                && AppState.sharedInstance.accu_Havnt_top2000 != nil
//            {
//                if var value = AppState.sharedInstance.accu_Havnt_top2000![genre] {
//                    value = value + 1
//                    AppState.sharedInstance.accu_Havnt_top2000![genre] = value
//                } else {
//                    AppState.sharedInstance.accu_Havnt_top2000![genre] = 1
//                }
//                
//                if var value = AppState.sharedInstance.accu_Havnt_top2000!["Total"] {
//                    value = value + 1
//                    AppState.sharedInstance.accu_Havnt_top2000!["Total"] = value
//                } else {
//                    AppState.sharedInstance.accu_Havnt_top2000!["Total"] = 1
//                }
//                
//                print(" accu_Havnt_top2000 \(AppState.sharedInstance.accu_Havnt_top2000) ")
//                FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child(status_haventWatched).setValue(AppState.sharedInstance.accu_Havnt_top2000!)
//            }
//        }
        
    }

}

//MARK: KolodaViewDelegate
extension RecomendationVC: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        cardHolderView.resetCurrentCardIndex()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        let movieDescriptionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDescriptionViewController") as! MovieDescriptionViewController!
        movieDescriptionViewController.movieDetail = ["imdbID": "\(AppState.sharedInstance.My_Like_Recom_MovieID_top2000[Int(index)])"]
        self.navigationController?.pushViewController(movieDescriptionViewController, animated: true)
    }
    
    
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaSwipeThresholdRatioMargin(koloda: KolodaView) -> CGFloat? {
        return 0.4
    }
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation.springBounciness = frameAnimationSpringBounciness
        animation.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func koloda(koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        return [.Up]
    }
    
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        switch direction {
        case .Left, .TopLeft, .BottomLeft:
            print("Disliked")
            SaveSwipeEntry(Int(index), Status: status_dislike)
            break
        case .Right, .TopRight, .BottomRight:
            print("Liked")
            SaveSwipeEntry(Int(index), Status: status_like)
            break
        case .Up:
            print("Haven't Watched")
            SaveSwipeEntry(Int(index), Status: status_haventWatched)
            break
        case .Down:
            print("Watchlist")
            SaveSwipeEntry(Int(index), Status: status_watchlist)
            break
        }
    }
}

//MARK: KolodaViewDataSource
extension RecomendationVC: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(AppState.sharedInstance.My_Like_Recom_MovieID_top2000.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let imgPoster = UIImageView(frame: koloda.frame)
        let imdbID = AppState.sharedInstance.My_Like_Recom_MovieID_top2000[Int(index)] ?? ""
        let posterURL = "http://img.omdbapi.com/?i=\(imdbID)&apikey=57288a3b&h=1000"
        let posterNSURL = NSURL(string: "\(posterURL)")
        
        print(" \(index) Movie: \(imdbID) , Image: \(posterURL)")
        imgPoster.setImageWithURL(posterNSURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.AllowInvalidSSLCertificates, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        return imgPoster
        //        return UIImageView(image: UIImage(named: "cards_\(index + 1)"))
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView",
                                                  owner: self, options: nil)[0] as? OverlayView
    }
    
}
