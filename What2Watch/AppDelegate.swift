//
//  AppDelegate.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import CoreData
import Mixpanel
import FBSDKCoreKit
import FBSDKLoginKit
//import Fabric
//import TwitterKit
import Firebase
import OAuthSwift
import IQKeyboardManagerSwift
import Alamofire
import SWRevealViewController

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    var ref: FIRDatabaseReference?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
          FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//        
//        //Fabric.with([Twitter.self])
//        
          let mixpanel = Mixpanel.sharedInstanceWithToken("57a85a364ed354c028734e7ab5de105b")
          mixpanel.track("App launched")
        
          FIRApp.configure()
        
          IQKeyboardManager.sharedManager().enable = true
        
          let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
          application.registerUserNotificationSettings(settings)
          application.registerForRemoteNotifications()
        
        
        /// Uncomnet this section for if user is logged in it redirect to main screen when application opens
        
        //try? FIRAuth.auth()?.signOut()
        
        if let user = FIRAuth.auth()?.currentUser
        {
            print("Loggedin in user: \(user)")
            print("swipedMovieCount : \(NSUserDefaults.standardUserDefaults().integerForKey("swipedMovieCount") as Int ?? 0)")
            
//            if let swipedMovieCount = NSUserDefaults.standardUserDefaults().integerForKey("swipedMovieCount") as Int? where swipedMovieCount >= 50 {
//                print("swipedMovieCount : ",swipedMovieCount)
//                
//                //if User has rate more than [ ] no of moview redirect hem to recommendation page
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                
//                let destinationController = storyboard.instantiateViewControllerWithIdentifier("RecomendationVC") as? RecomendationVC
//                let frontNavigationController = UINavigationController(rootViewController: destinationController!)
//                frontNavigationController.navigationBarHidden = true
//                
//                let rearViewController = storyboard.instantiateViewControllerWithIdentifier("MySlideMenuController") as? MySlideMenuController
//                let mainRevealController = SWRevealViewController()
//                
//                mainRevealController.rearViewController = rearViewController
//                mainRevealController.frontViewController = frontNavigationController
//                
//                let navigationController = UINavigationController(rootViewController: mainRevealController)
//                navigationController.navigationBarHidden = true
//                
//                self.window?.backgroundColor = UIColor.clearColor()
//                self.window!.rootViewController = mainRevealController
//                self.window?.makeKeyAndVisible()
//            }
//            else
//            {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let rootViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as? UIViewController
                let navigationController = UINavigationController(rootViewController: rootViewController!)
                navigationController.navigationBarHidden = true // or not, your choice.
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window!.rootViewController = navigationController
                self.window!.makeKeyAndVisible()
//            }
        }
        
//        let movieDetail = "http://www.omdbapi.com/"  //http:// www.omdbapi.com/?i=(*imdbID*)&plot=short&r=json
//        Alamofire.request(.GET, movieDetail, parameters: ["i": "tt0091203", "apikey":"57288a3b", "plot":"short", "r":"json"])
//            .responseJSON { response in
//                debugPrint(response)
//                
//                if let JSON = response.result.value as? NSDictionary {
//                    print("Success with JSON: \(JSON)")
//                    //let cat = JSON["data"] as? Array<NSDictionary>
//                    //print("cat : \(cat)")
//                }
//                
//        }
        
        return true
    }
    
    func saveData() {
        
        self.ref = FIRDatabase.database().reference()
        
        if let path = NSBundle.mainBundle().pathForResource("sample", ofType: "json")
        {
            
            let data = try? NSData(contentsOfFile: path, options: [])
            let jsonResult = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
            
            if let array = jsonResult as? NSArray {
                
                print(array.count)
                
                for item in array {
                    
                    self.ref?.child("movies").childByAutoId().setValue(item)
                }
            }
            
            self.ref = FIRDatabase.database().reference()

        }
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        print(deviceToken)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        
    }
    
    
    func applicationHandleOpenURL(url: NSURL) {
        if (url.host == "oauth-callback") {
            OAuthSwift.handleOpenURL(url)
        } else {
            // Google provider is the only one wuth your.bundle.id url schema.
            OAuthSwift.handleOpenURL(url)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        applicationHandleOpenURL(url)
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        applicationHandleOpenURL(url)
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            openURL: url,
            sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String,
            annotation: nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
        }
        
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.harloch.Connect_App" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("What2Watch", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    //MARK: Helper method to convert the NSDate to NSDateComponents
    func dateComponentFromNSDate(date: NSDate)-> NSDateComponents{
        
        let calendarUnit: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let dateComponents = NSCalendar.currentCalendar().components(calendarUnit, fromDate: date)
        return dateComponents
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // ...
    }
    
}


class UIApplicationTimer: UIApplication {
    
    static let ApplicationDidTimoutNotification = "AppTimout"
    
    // The timeout in seconds for when to fire the idle timer.
    let timeoutInSeconds: NSTimeInterval = 10 //* 60
    
    var idleTimer: NSTimer?
    
    // Listen for any touch. If the screen receives a touch, the timer is reset.
    override func sendEvent(event: UIEvent) {
        super.sendEvent(event)
        
        if idleTimer != nil {
            self.resetIdleTimer()
        }
        
        if let touches = event.allTouches() {
            for touch in touches {
                if touch.phase == UITouchPhase.Began {
                    self.resetIdleTimer()
                }
            }
        }
    }
    
    // Resent the timer because there was user interaction.
    func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutInSeconds, target: self, selector: #selector(UIApplicationTimer.idleTimerExceeded), userInfo: nil, repeats: false)
    }
    
    // If the timer reaches the limit as defined in timeoutInSeconds, post this notification.
    func idleTimerExceeded() {
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationTimer.ApplicationDidTimoutNotification, object: nil)
    }
}

