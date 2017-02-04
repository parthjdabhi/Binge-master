//
//  WatchlistViewController.swift
//  What2Watch
//
//  Created by iParth on 8/3/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseDatabase

class WatchlistViewController: UIViewController {
    
    @IBOutlet var btnMenu: UIButton?
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var lblNavTitle: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblValue: UILabel!
    
    var movieWatched:Array<[String:AnyObject]> = []
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        if let revealVC = self.revealViewController() {
            self.btnMenu?.addTarget(revealVC, action: #selector(revealVC.revealToggle(_:)), forControlEvents: .TouchUpInside)
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer());
            //            self.navigationController?.navigationBar.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Waiting..")
        ref.child("swiped").child(AppState.MyUserID())
            //.queryOrderedByChild("status")
            //.queryEqualToValue("Watchlist")
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                
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
                        self.tableview.reloadData()
                    }
                } else {
                    // Not found any movie
                }
                
                }, withCancelBlock: { error in
                    print(error.description)
                    CommonUtils.sharedUtils.hideProgress()
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func actionBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Delegates
    // MARK: -  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.lblValue.text = "\(self.movieWatched.count)"
        if self.movieWatched.count == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "Currently you do not have any movie in watchlist!"
            emptyLabel.textColor = UIColor.lightGrayColor();
            emptyLabel.textAlignment = .Center;
            emptyLabel.numberOfLines = 3
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return self.movieWatched.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:MovieListTableViewCell = tableView.dequeueReusableCellWithIdentifier(MovieListTableViewCell.identifier, forIndexPath: indexPath) as! MovieListTableViewCell
        cell.lblTitle.text = self.movieWatched[indexPath.row]["movieTitle"] as? String ?? ""
        
        if let IsLike = self.movieWatched[indexPath.row]["status"] as? String where IsLike == "Liked" {
            cell.lblValue.text = "Liked"
            cell.lblValue.textColor = AppState.sharedInstance.clrYellow
        }
        if let IsWatchList = self.movieWatched[indexPath.row]["status"] as? String where IsWatchList == "Watchlist" {
            cell.lblValue.text = "Watchlist"
            cell.lblValue.textColor = AppState.sharedInstance.clrYellow
        }
        if let IsNotWatched = self.movieWatched[indexPath.row]["status"] as? String where IsNotWatched == "Haven't Watched" {
            cell.lblValue.text = "Haven't Watched"
            cell.lblValue.textColor = AppState.sharedInstance.clrYellow
        }
        if let IsDislike = self.movieWatched[indexPath.row]["status"] as? String where IsDislike == "Disliked" {
            cell.lblValue.text = "Disliked"
            cell.lblValue.textColor = AppState.sharedInstance.clrYellow
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}