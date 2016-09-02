//
//  MovieWatchedVC.swift
//  What2Watch
//
//  Created by iParth on 8/16/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class MovieWatchedVC: UIViewController {
    
    @IBOutlet var btnBack: UIButton?
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var lblNavTitle: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblValue: UILabel!
    
    var movieWatched:Array<[String:AnyObject]> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.lblValue.text = "\(self.movieWatched.count)"
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
        if self.movieWatched.count == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "Currently you do not have any watched movies!"
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