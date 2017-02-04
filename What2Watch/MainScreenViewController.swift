//
//  ViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SWRevealViewController
import UIActivityIndicator_for_SDWebImage
import SVProgressHUD

import Koloda
import pop

import TransitionTreasury
import TransitionAnimation

//private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.05

class MainScreenViewController: UIViewController, ModalTransitionDelegate, UINavigationControllerDelegate {
 
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBOutlet var profileInfo: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var poster: UIImageView!
    @IBOutlet var btnMenu: UIButton?
    @IBOutlet var btnSearch: UIButton?
    @IBOutlet var imgInstruction: UIImageView!
    //@IBOutlet var draggableBackground: DraggableViewBackground!
    @IBOutlet weak var cardHolderView: CustomKolodaView!
    
    var currentIndex:Int = 0   /// current image index
    var numberOfItems: Int = 0  /// number of images
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    //var draggableBackground: DraggableViewBackground!
    
    var movies:Array<[String:AnyObject]> = []
    var accu_movies:Array<[String:AnyObject]> = []
    
    var lastSwipedMovie:String?
    
    var searchResultController:movieSearchController!
    var searchString:String = ""
    var movieSearched:Array<[String:AnyObject]> = []
    var myTimer:NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardHolderView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        cardHolderView.countOfVisibleCards = kolodaCountOfVisibleCards
        cardHolderView.delegate = self
        cardHolderView.dataSource = self
        cardHolderView.animator = BackgroundKolodaAnimator(koloda: cardHolderView)
        cardHolderView.backgroundColor = UIColor.blackColor()
        
        imgInstruction.alpha = 0
        
        let imgTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(MainScreenViewController.onTapInstructionOverlay(_:)) )
        imgTapGesture.numberOfTouchesRequired = 1
        imgTapGesture.cancelsTouchesInView = true
        imgTapGesture.minimumPressDuration = 0
        imgInstruction.addGestureRecognizer(imgTapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainScreenViewController.applicationDidTimout(_:)), name: UIApplicationTimer.ApplicationDidTimoutNotification, object: nil)
        
        searchResultController = movieSearchController()
        searchResultController.delegate = self
        
        // Init menu button action for menu
        if let revealVC = self.revealViewController() {
            self.btnMenu?.addTarget(revealVC, action: #selector(revealVC.revealToggle(_:)), forControlEvents: .TouchUpInside)
//            self.view.addGestureRecognizer(revealVC.panGestureRecognizer());
//            self.navigationController?.navigationBar.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        ref = FIRDatabase.database().reference()
        
        if let lastSwiped_top2000 = NSUserDefaults.standardUserDefaults().objectForKey("lastSwiped_top2000") as? String {
            self.getMoviewRecord(lastSwiped_top2000)
        } else {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Updating details..")
            ref.child("users").child(AppState.MyUserID()).child("lastSwiped").observeSingleEventOfType(.Value, withBlock: { snapshot in
                CommonUtils.sharedUtils.hideProgress()
                if snapshot.exists() {
                    
                    print(snapshot.childrenCount)
                    
                    if let lastSwipedMovie = snapshot.valueInExportFormat() as? NSDictionary {
                        let imdbID_top2000 = lastSwipedMovie["top2000"] as? String ?? ""
                        NSUserDefaults.standardUserDefaults().setObject(imdbID_top2000, forKey: "lastSwiped_top2000")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.getMoviewRecord(imdbID_top2000)
                    } else {
                        self.getMoviewRecord(nil)
                    }
                    
                } else {
                    // Not found any movie
                    self.getMoviewRecord(nil)
                }
                
                }, withCancelBlock: { error in
                    print(error.description)
                    //MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.getMoviewRecord(nil)
            })
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("isInstructionShown") == nil {
            showInstruction(1)
        }
        
        refreshAccuracyCounts({})
        
        //draggableBackground.cardMovies = self.movies
        //draggableBackground.loadCards()
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.LoadMoreMovieRecords(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Action
     */
    @IBAction func logoutButton(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            dismissViewControllerAnimated(true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignInViewController") as! FirebaseSignInViewController!
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func menuButton(sender: AnyObject) {
        
    }
    
    @IBAction func onSearchButtonAction(sender: AnyObject) {
        //OpenMovieDescription(ForIndex: Int(cardHolderView.currentCardIndex))
        
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        //searchController.searchBar.text = self.searchBar.text
        //searchController.searchBar.showsSearchResultsButton = true
        self.presentViewController(searchController, animated: true, completion: nil)
    }
    
    /**
     Custom functions
     */
    
    func refreshAccuracyCounts(completion: ()->()) {
        //accuracy_top2000
        dispatch_group_enter(globalGroup)
        ref.child("users").child(AppState.MyUserID()).child("accuracy_top2000").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            CommonUtils.sharedUtils.hideProgress()
            AppState.sharedInstance.accu_All_top2000 = Dictionary<String,Int>()
            AppState.sharedInstance.accu_Like_top2000 = Dictionary<String,Int>()
            AppState.sharedInstance.accu_Dislike_top2000 = Dictionary<String,Int>()
            AppState.sharedInstance.accu_Watched_top2000 = Dictionary<String,Int>()
            AppState.sharedInstance.accu_Havnt_top2000 = Dictionary<String,Int>()
            
            if snapshot.exists() {
                print(snapshot.childrenCount)
                let top2000 = snapshot.valueInExportFormat() as? NSDictionary
                if let accu_All_top2000 = top2000?["all"] as? NSDictionary {
                    for key : AnyObject in accu_All_top2000.allKeys {
                        let stringKey = key as! String
                        if let keyValue = accu_All_top2000.valueForKey(stringKey) as? Int {
                            AppState.sharedInstance.accu_All_top2000![stringKey] = keyValue
                        }
                    }
                }
                if let accu_Like_top2000 = top2000?[status_like] as? NSDictionary {
                    for key : AnyObject in accu_Like_top2000.allKeys {
                        let stringKey = key as! String
                        if let keyValue = accu_Like_top2000.valueForKey(stringKey) as? Int {
                            AppState.sharedInstance.accu_Like_top2000![stringKey] = keyValue
                        }
                    }
                }
                if let accu_Dislike_top2000 = top2000?[status_dislike] as? NSDictionary {
                    for key : AnyObject in accu_Dislike_top2000.allKeys {
                        let stringKey = key as! String
                        if let keyValue = accu_Dislike_top2000.valueForKey(stringKey) as? Int {
                            AppState.sharedInstance.accu_Dislike_top2000![stringKey] = keyValue
                        }
                    }
                }
                if let accu_Watched_top2000 = top2000?[status_watchlist] as? NSDictionary {
                    for key : AnyObject in accu_Watched_top2000.allKeys {
                        let stringKey = key as! String
                        if let keyValue = accu_Watched_top2000.valueForKey(stringKey) as? Int {
                            AppState.sharedInstance.accu_Watched_top2000![stringKey] = keyValue
                        }
                    }
                }
                if let accu_Havnt_top2000 = top2000?[status_haventWatched] as? NSDictionary {
                    for key : AnyObject in accu_Havnt_top2000.allKeys {
                        let stringKey = key as! String
                        if let keyValue = accu_Havnt_top2000.valueForKey(stringKey) as? Int {
                            AppState.sharedInstance.accu_Havnt_top2000![stringKey] = keyValue
                        }
                    }
                }
                
            } else {
                // Not have accuracy data
                // AppState.sharedInstance.accuracy_top2000 = [:]
            }
            dispatch_group_leave(globalGroup)
            completion()
        }, withCancelBlock: { error in
            print(error.description)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            dispatch_group_leave(globalGroup)
            completion()
        })
        
    }
    
    func onTapInstructionOverlay(sender: UILongPressGestureRecognizer? = nil) {
        //imgInstruction.hidden = true
        showInstruction(0)
        NSUserDefaults.standardUserDefaults().setObject("true", forKey: "isInstructionShown")
    }
    
    func showInstruction(value:Int) {
        let opacityAnimation:POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha)
        opacityAnimation.toValue = value
        imgInstruction.pop_addAnimation(opacityAnimation, forKey: "opacityAnimation")
    }
    
    func getMoviewRecord(skipToMovie:String?) {
        if let top2000 = NSUserDefaults.standardUserDefaults().objectForKey("top2000") as? Array<[String:AnyObject]> {
            self.movies = top2000
            self.currentIndex = skipIndexToMovie(skipToMovie)
            //self.getImage(self.currentIndex)
            self.numberOfItems += top2000.count
            
            if self.currentIndex > 0 {
                self.movies.removeFirst(self.currentIndex)
            }
            if AppState.sharedInstance.accu_All_top2000 == nil {
                self.refreshAccuracyCounts({
                    self.filterDatawithAccuracy()
                    self.cardHolderView.reloadData()
                })
            } else {
                self.filterDatawithAccuracy()
                self.cardHolderView.reloadData()
            }
            
//            draggableBackground.movies = self.movies
//            draggableBackground.loadCardsFromIndex(skipIndexToMovie(skipToMovie))
        } else {
            //Load  Data first time from firebase
            CommonUtils.sharedUtils.showProgress(self.view, label: "We are loading the first poster!")
            dispatch_group_enter(globalGroup)
            ref.child("movies").child("top2000").queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
                CommonUtils.sharedUtils.hideProgress()
                dispatch_group_leave(globalGroup)
                if snapshot.exists() {
                    
                    print(snapshot.childrenCount)
                    let top2000 = snapshot.valueInExportFormat() as? NSDictionary
                    if top2000 != nil {
                        NSUserDefaults.standardUserDefaults().setObject(top2000, forKey: "top2000")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    
                    let enumerator = snapshot.children
                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                        //print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                        if var dic = rest.value as? [String:AnyObject] {
                            dic["key"] = rest.key
                            self.movies.append(dic)
                        }
                    }
                    
                    if self.movies.count > 0 {
                        NSUserDefaults.standardUserDefaults().setObject(self.movies, forKey: "top2000")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    
                    
                    self.currentIndex = self.skipIndexToMovie(skipToMovie)
//                    self.getImage(self.currentIndex)
//                    self.numberOfItems += Int(snapshot.childrenCount)
                    
                    if self.currentIndex > 0 {
                        self.movies.removeFirst(self.currentIndex-1)
                    }
                    
                    
                    if AppState.sharedInstance.accu_All_top2000 == nil {
                        self.refreshAccuracyCounts({
                            self.filterDatawithAccuracy()
                            self.cardHolderView.reloadData()
                        })
                    } else {
                        self.filterDatawithAccuracy()
                        self.cardHolderView.reloadData()
                    }
//                    self.draggableBackground.movies = self.movies
//                    self.draggableBackground.loadCardsFromIndex(self.skipIndexToMovie(skipToMovie))
                } else {
                    // Not found any movie
                }
                
                }, withCancelBlock: { error in
                    print(error.description)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    dispatch_group_leave(globalGroup)
            })
            
            dispatch_group_notify(globalGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    print(" 0 - - - - - - - - - - -  - - - - - - - - - --  - - - - - -- - - - -  - - -- - - - - - - - - - - - - - -")
                    
                    
                })
            })
        }
    }
    
    func skipIndexToMovie(skipToMovie:String?) -> Int {
        if skipToMovie == nil {
            return 0
        }
        for (index, element) in self.movies.enumerate() {
            print("Item \(index): \(element)")
            if let imdbId = element["imdbID"] as? String where imdbId == skipToMovie! {
                return index+1
            }
        }
        return 0
    }
    
    func SaveSwipeEntry(forIndex: Int,Status: String)
    {
        if forIndex >= movies.count {
            return
        }
        
        var Movie =  movies[forIndex]
        Movie["status"] = Status

        FIRDatabase.database().reference().child("swiped").child(FIRAuth.auth()?.currentUser?.uid ?? "").child(Movie["key"] as? String ?? "").setValue(Movie)
        
        let imdbID = Movie["imdbID"] as? String ?? ""
        FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("lastSwiped").child("top2000").setValue(imdbID)
        
        if let genre = movies[forIndex]["genre"] as? String
            where AppState.sharedInstance.accu_All_top2000 != nil
        {
            if var value = AppState.sharedInstance.accu_All_top2000![genre] {
                value = value + 1
                AppState.sharedInstance.accu_All_top2000![genre] = value
            } else {
                AppState.sharedInstance.accu_All_top2000![genre] = 1
            }
            
            if var value = AppState.sharedInstance.accu_All_top2000!["Total"] {
                value = value + 1
                AppState.sharedInstance.accu_All_top2000!["Total"] = value
            } else {
                AppState.sharedInstance.accu_All_top2000!["Total"] = 1
            }
            
            print(" accu_All_top2000 \(AppState.sharedInstance.accu_All_top2000) ")
            FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child("all").setValue(AppState.sharedInstance.accu_All_top2000!)
            
            if Status == status_like
                && AppState.sharedInstance.accu_Like_top2000 != nil
            {
                if var value = AppState.sharedInstance.accu_Like_top2000![genre] {
                    value = value + 1
                    AppState.sharedInstance.accu_Like_top2000![genre] = value
                } else {
                    AppState.sharedInstance.accu_Like_top2000![genre] = 1
                }
                
                if var value = AppState.sharedInstance.accu_Like_top2000!["Total"] {
                    value = value + 1
                    AppState.sharedInstance.accu_Like_top2000!["Total"] = value
                } else {
                    AppState.sharedInstance.accu_Like_top2000!["Total"] = 1
                }
                
                print(" accu_Like_top2000 \(AppState.sharedInstance.accu_Like_top2000) ")
                FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child(status_like).setValue(AppState.sharedInstance.accu_Like_top2000!)
            }
            else if Status == status_dislike
                && AppState.sharedInstance.accu_Dislike_top2000 != nil
            {
                if var value = AppState.sharedInstance.accu_Dislike_top2000![genre] {
                    value = value + 1
                    AppState.sharedInstance.accu_Dislike_top2000![genre] = value
                } else {
                    AppState.sharedInstance.accu_Dislike_top2000![genre] = 1
                }
                
                if var value = AppState.sharedInstance.accu_Dislike_top2000!["Total"] {
                    value = value + 1
                    AppState.sharedInstance.accu_Dislike_top2000!["Total"] = value
                } else {
                    AppState.sharedInstance.accu_Dislike_top2000!["Total"] = 1
                }
                
                print(" accu_Dislike_top2000 \(AppState.sharedInstance.accu_Dislike_top2000) ")
                FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child(status_dislike).setValue(AppState.sharedInstance.accu_Dislike_top2000!)
            }
            else if Status == status_watchlist
                && AppState.sharedInstance.accu_Watched_top2000 != nil
            {
                if var value = AppState.sharedInstance.accu_Watched_top2000![genre] {
                    value = value + 1
                    AppState.sharedInstance.accu_Watched_top2000![genre] = value
                } else {
                    AppState.sharedInstance.accu_Watched_top2000![genre] = 1
                }
                
                if var value = AppState.sharedInstance.accu_Watched_top2000!["Total"] {
                    value = value + 1
                    AppState.sharedInstance.accu_Watched_top2000!["Total"] = value
                } else {
                    AppState.sharedInstance.accu_Watched_top2000!["Total"] = 1
                }
                
                print(" accu_Watched_top2000 \(AppState.sharedInstance.accu_Watched_top2000) ")
                FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child(status_watchlist).setValue(AppState.sharedInstance.accu_Watched_top2000!)
            }
            else if Status == status_haventWatched
                && AppState.sharedInstance.accu_Havnt_top2000 != nil
            {
                if var value = AppState.sharedInstance.accu_Havnt_top2000![genre] {
                    value = value + 1
                    AppState.sharedInstance.accu_Havnt_top2000![genre] = value
                } else {
                    AppState.sharedInstance.accu_Havnt_top2000![genre] = 1
                }
                
                if var value = AppState.sharedInstance.accu_Havnt_top2000!["Total"] {
                    value = value + 1
                    AppState.sharedInstance.accu_Havnt_top2000!["Total"] = value
                } else {
                    AppState.sharedInstance.accu_Havnt_top2000!["Total"] = 1
                }
                
                print(" accu_Havnt_top2000 \(AppState.sharedInstance.accu_Havnt_top2000) ")
                FIRDatabase.database().reference().child("users").child(AppState.MyUserID()).child("accuracy_top2000").child(status_haventWatched).setValue(AppState.sharedInstance.accu_Havnt_top2000!)
            }
        }
        
        NSUserDefaults.standardUserDefaults().setObject(imdbID, forKey: "lastSwiped_top2000")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // The callback for when the timeout was fired.
    func applicationDidTimout(notification: NSNotification) {
        showInstruction(1)
    }
    
    func OpenMovieDescription(ForIndex index:Int) {
                let movieDescriptionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDescriptionViewController") as! MovieDescriptionViewController!
                movieDescriptionViewController.movieDetail = movies[Int(index)] as? [String:String]
                self.navigationController?.pushViewController(movieDescriptionViewController, animated: true)
        
//        let updateTransition1: TRPushTransitionMethod = .Blixt(keyView: self.cardHolderView, to: CGRect(x: self.cardHolderView.frame.size.width/3, y: self.cardHolderView.frame.size.height/2, width: 0, height: 0))
//        //let updateTransition2: TRPushTransitionMethod = .IBanTang(keyView: self.cardHolderView)
//        
//        let movieDescriptionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDescriptionViewController") as! MovieDescriptionViewController!
//        movieDescriptionViewController.movieDetail = movies[Int(index)] as? [String:String]
//        //navigationController?.tr_pushViewController(movieDescriptionViewController, method: updateTransition1)
//        
//        
////        var trans1 = PresentTransition(name: "Twitter", imageName: "Twitter60x60", presentMethod: .Twitter, interactive: false)
//        
//        movieDescriptionViewController.modalDelegate = self
//        tr_presentViewController(movieDescriptionViewController, method: TRPresentTransitionMethod.Twitter, statusBarStyle: TRStatusBarStyle.Default) {
//            print("Present finished.")
//        }
        
        //        let updateTransition3: TRPresentTransitionMethod = .Elevate(maskView: self.cardHolderView, to: UIScreen.mainScreen().tr_center)
        //        let nav = UINavigationController(rootViewController: movieDescriptionViewController)
        //
        //        present
        //        tr_presentViewContr (nav, method: updateTransition, completion: {
        //            print("Present finished.")
        //        })
    }
}

//MARK: KolodaViewDelegate
extension MainScreenViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        cardHolderView.resetCurrentCardIndex()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        OpenMovieDescription(ForIndex: Int(index))
        cardHolderView.currentCardIndex
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
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation.springBounciness = frameAnimationSpringBounciness
        animation.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func koloda(koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        return [.Left, .Right, .Up, .Down]
    }
    
    func kolodaSwipeThresholdRatioMargin(koloda: KolodaView) -> CGFloat? {
        return 0.4
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
extension MainScreenViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(movies.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        
        let imgPoster = UIImageView(frame: koloda.frame)
        let imdbID = movies[Int(index)]["imdbID"] as? String ?? ""
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
    
    
    /*
     Filter with accuracy
     criteria:
     
     Dislike = x = 15%
     Like = y = 35%
     Watchlist = a = 20%
     Haven’t Watched = b = 30%
     Amount Swiped = z
     
     Answer = (x(z))*(y(z))*(a(z))*(b(*z*))
     Answer / x = Dislike Percentage
     Answer / y = Like Percentage
     Answer / a = Watchlist Percentage
     Answer / b = Watched Percentage
     
     If Dislike Percentage > 25% of Answer, recommend 50% less of most disliked genre.
     If Like Percentage > 45% of Answer, recommend 50% more of most liked genre.
     If Watchlist Percentage > 35% of Answer, recommend 50% more of most watchlisted genre.
     If Watched Percentage > 40% of Answer, recommend 50% more of most watched genre.

     */
    
    func filterDatawithAccuracy()
    {
        if AppState.sharedInstance.accu_All_top2000 != nil
        {
            let totalSwiped:Double = Double(AppState.sharedInstance.accu_All_top2000?["Total"] ?? 0)
            let totalLiked:Double = Double(AppState.sharedInstance.accu_Like_top2000?["Total"] ?? 0)
            let totalDisLiked:Double = Double(AppState.sharedInstance.accu_Dislike_top2000?["Total"] ?? 0)
            let totalWatchlist:Double = Double(AppState.sharedInstance.accu_Watched_top2000?["Total"] ?? 0)
            let totalHaventWatched:Double = Double(AppState.sharedInstance.accu_Havnt_top2000?["Total"] ?? 0)
            
            if totalLiked > 0
                && totalDisLiked > 0
                && totalWatchlist > 0
                && totalHaventWatched > 0
            {
                let per_Dislike = ((totalDisLiked / totalSwiped) * 15)
                let per_Liked = ((totalLiked / totalSwiped) * 35)
                let per_Watchlist = ((totalWatchlist / totalSwiped) * 20)
                let per_HaventWatched = ((totalHaventWatched / totalSwiped) * 30)
                
                print("totalDisLiked % : \(per_Dislike)")
                print("totalLiked % : \(per_Liked)")
                print("totalWatchlist % : \(per_Watchlist)")
                print("totalHaventWatched % : \(per_HaventWatched)")
                
                let Answer = per_Dislike * per_Liked  * per_Watchlist  * per_HaventWatched
                print("Answer : \(Answer)")
                
                let Answer1 = ((totalDisLiked / totalSwiped) * 15) * ((totalLiked / totalSwiped) * 35)  * ((totalWatchlist / totalSwiped) * 20)  * ((totalHaventWatched / totalSwiped) * 30)
                print("Answer1 : \(Answer1)")
                
                let dislike_per = (Answer / per_Dislike)
                let liked_per = (Answer / per_Liked)
                let watchlist_per = (per_Watchlist / Answer)
                let HaventWatched_per = (per_HaventWatched / Answer)
                
                //---------------------------------------------------
                // i am getting this final percentage as wrong
                //---------------------------------------------------
                print("dislike_per % : \(dislike_per)")
                print("liked_per % : \(liked_per)")
                print("watchlist_per % : \(watchlist_per)")
                print("HaventWatched_per % : \(HaventWatched_per)")
                
                //---------------------------------------------------
                // Let's start calculation with : (per_Dislike) Dislike = x = 15% ...
                //---------------------------------------------------
                
                // If Dislike Percentage > 25% of Answer, recommend 50% less of most disliked genre.
                // If Like Percentage > 45% of Answer, recommend 50% more of most liked genre.
                // If Watchlist Percentage > 35% of Answer, recommend 50% more of most watchlisted genre.
                // If Watched Percentage > 40% of Answer, recommend 50% more of most watched genre.
                
                print("Dislike \(per_Dislike) Movie : recommend 50% less of \(getGenreWithHeighestValue(AppState.sharedInstance.accu_Dislike_top2000).genre ?? "") genre")
                print("Like \(per_Liked) Movie : recommend 50% more of \(getGenreWithHeighestValue(AppState.sharedInstance.accu_Like_top2000).genre ?? "")  genre")
                print("Watchlist \(per_Watchlist) Movie : 50% more of \(getGenreWithHeighestValue(AppState.sharedInstance.accu_Watched_top2000).genre ?? "") genre")
                print("Watched \(per_HaventWatched) Movie : 50% more of \(getGenreWithHeighestValue(AppState.sharedInstance.accu_Havnt_top2000).genre ?? "") genre")
                
                if per_Dislike >= 25 {
                    //If Dislike Percentage > 25% of Answer, recommend 50% less of most disliked genre.
                    if  let genre = getGenreWithHeighestValue(AppState.sharedInstance.accu_Dislike_top2000).genre {
                        print("recommend 50% \(per_Dislike) less of \(genre) genre")
                        let FilteredMovie = filterMoviesWithGenre(getGenreWithHeighestValue(AppState.sharedInstance.accu_Dislike_top2000).genre!, Probability: 50.0,type: matchType.Least)
                        movies = FilteredMovie
                        cardHolderView.reloadData()
                    }
                }
                else if per_Dislike >= 45 {
                    //If Like Percentage > 45% of Answer, recommend 50% more of most liked genre.
                    if  let genre = getGenreWithHeighestValue(AppState.sharedInstance.accu_Like_top2000).genre {
                        print("recommend 50% \(per_Dislike) more of \(genre) genre")
                        let FilteredMovie = filterMoviesWithGenre(getGenreWithHeighestValue(AppState.sharedInstance.accu_Like_top2000).genre!, Probability: 50.0,type: matchType.Most)
                        movies = FilteredMovie
                        cardHolderView.reloadData()
                    }
                }
                else if per_HaventWatched >= 30 {
                    //If Watchlist Percentage > 35% of Answer, recommend 50% more of most watchlisted genre.
                    if  let genre = getGenreWithHeighestValue(AppState.sharedInstance.accu_Havnt_top2000).genre {
                        print("recommend 50% \(per_Dislike) more of \(genre) genre")
                        let FilteredMovie = filterMoviesWithGenre(getGenreWithHeighestValue(AppState.sharedInstance.accu_Havnt_top2000).genre!, Probability: 50.0,type: matchType.Most)
                        movies = FilteredMovie
                        cardHolderView.reloadData()
                    }
                }
                else if per_Watchlist >= 40 {
                    //If Watched Percentage > 40% of Answer, recommend 50% more of most watched genre.
                    if  let genre = getGenreWithHeighestValue(AppState.sharedInstance.accu_Watched_top2000).genre {
                        print("recommend 50% \(per_Dislike) more of \(genre) genre")
                        let FilteredMovie = filterMoviesWithGenre(getGenreWithHeighestValue(AppState.sharedInstance.accu_Watched_top2000).genre!, Probability: 50.0,type: matchType.Most)
                        movies = FilteredMovie
                        cardHolderView.reloadData()
                    }
                }
            }
        }
    }
    
    func getGenreWithHeighestValue(Stastics:Dictionary<String,Int>?) -> (genre:String?,Value:Int?) {
        if Stastics == nil {
            return (nil,0)
        }
        var Highest = 0
        var Genre = ""
        for (key, Value) in Stastics! {
            //print("key: \(key)")
            if Value > Highest
                && key != "Total"
            {
                Highest = Value
                Genre = key
            }
        }
        print("Highest Gener with value : \(Highest) \(Genre)")
        return (Genre,Highest)
    }
    
    enum matchType {
        case Least
        case Most
    }
    
    func filterMoviesWithGenre(genre:String,Probability:Double,type:matchType) -> (Array<[String:AnyObject]>) {
        
        var TotalFound = 0
        var skipped = 0
        
        let FilteredMovie = self.movies.filter { (Movie:[String : AnyObject]) -> Bool in
            switch (type) {
                case matchType.Least:
                    if let movieGenre = Movie["genre"] as? String
                        where movieGenre == genre
                    {
                        TotalFound = TotalFound + 1
                        let randomNumber = randomPercent()
                        if randomNumber < Probability {
                            return true
                        } else {
                            skipped = skipped + 1
                            return false
                        }
                    }
                    return true
                case matchType.Most:
                    if let movieGenre = Movie["genre"] as? String
                        where movieGenre != genre
                    {
                        TotalFound = TotalFound + 1
                        let randomNumber = randomPercent()
                        if randomNumber < Probability {
                            return true
                        } else {
                            skipped = skipped + 1
                            return false
                        }
                    }
                    return true
            }
        }
        print("\((type==matchType.Least) ? "Least" : "Most") Filtered \(FilteredMovie.count) movie from \(self.movies.count) with probability of \(Probability) of genre \(genre) \n TotalFound \(TotalFound) & skipped = \(skipped)")
         
        return FilteredMovie
    }
    
    // create a random percent, with a precision of one decimal place
    func randomPercent() -> Double {
        return Double(arc4random() % 1000) / 10.0;
    }
    
    
    //MARK: Search
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
        FIRDatabase.database().reference().child("movies").child("top2000").queryOrderedByChild("movieTitle").queryStartingAtValue(searchString).observeEventType(.Value, withBlock: { snapshot in
            
            self.movieSearched.removeAll()
            
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
                
                self.movieSearched.append(placeDict)
                //print(placeDict)
            }
            dispatch_group_leave(myGroup)
        })
        dispatch_group_notify(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                // update UI
                SVProgressHUD.dismiss()
                //self.isRefreshingData = false
                
                print(self.movieSearched.count)
                self.searchResultController.reloadDataWithArray(self.movieSearched)
            }
        }
    }
}

extension MainScreenViewController: UISearchBarDelegate {
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

extension MainScreenViewController: searchDelegate {
    
    func onItemSelected(movie: Dictionary<String,AnyObject>) {
        
        print(" searchDelegate - onItemSelected :  \(movie)")
        
        //selectedUsers.append(bar)
        //self.lblMembersCount.text = "Member : \(selectedUsers.count)"
        //        let index = filteredBars.indexOf {
        //            //($0["key"] as? String != nil && bar["key"] as? String != nil)
        //            if let key1 = $0["key"] as? String, key2 = bar["key"] as? String where key1 == key2 {
        //                return true
        //            }
        //            return false
        //        }
        
    }
}