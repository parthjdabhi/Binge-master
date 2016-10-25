//
//  MyGroupVC.swift
//  What2Watch
//
//  Created by iParth on 10/25/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

import Firebase
import SDWebImage
import SVProgressHUD
import SWRevealViewController
import UIActivityIndicator_for_SDWebImage


class MyGroupVC: UIViewController, UITabBarDelegate, UITableViewDataSource {

    // MARK: - VC Outlets
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnByYourself: UIButton!
    @IBOutlet var btnByFriends: UIButton!
    @IBOutlet var tblGroupList: UITableView!
    
    // MARK: - VC Properties
    //let model = generateRandomData()
    var storedOffsets = [Int: CGFloat]()
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    var groups:Array<[String:AnyObject]> = []
    
    // MARK: - VC Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Init menu button action for menu
        if let revealVC = self.revealViewController() {
            self.btnMenu.addTarget(revealVC, action: #selector(revealVC.revealToggle(_:)), forControlEvents: .TouchUpInside)
//            self.view.addGestureRecognizer(revealVC.panGestureRecognizer());
//            self.navigationController?.navigationBar.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        tblGroupList.rowHeight = 88
    }
    
    override func viewWillAppear(animated: Bool) {
        getGroups()
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
    
    @IBAction func actionCreateGroup(sender: AnyObject) {
        let createGroup = self.storyboard?.instantiateViewControllerWithIdentifier("CreateGroupVC") as! CreateGroupVC
        self.navigationController?.pushViewController(createGroup, animated: true)
    }
    
    
    // Perform the search.
    private func getGroups(showLoader:Bool = true)
    {
        if showLoader == true {
            SVProgressHUD.showWithStatus("Loading..")
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
        FIRDatabase.database().reference().child("groups").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            myGroups.removeAll()
            
            print("\(NSDate().timeIntervalSince1970) -- \(snapshot.childrenCount)")
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
                
                myGroups.append(placeDict)
                //print(placeDict)
            }
            dispatch_group_leave(myGroup)
        })
        dispatch_group_notify(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                // update UI
                SVProgressHUD.dismiss()
                //self.isRefreshingData = false
                
                print(myGroups.count)
                self.tblGroupList.reloadData()
            }
        }
    }
    
    // MARK: - Delegates & DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:MyGroupTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)  as! MyGroupTableViewCell
        
        cell.imgGroup?.setCornerRadious(cell.imgGroup.frame.width/2)
        cell.imgGroup?.setBorder(1, color: UIColor.lightGrayColor())
        cell.imgGroup?.setImageWithURL(NSURL(string: (myGroups[indexPath.row]["imageUrl"] as? String ?? "")), placeholderImage: UIImage(named: "user.png"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        cell.lblGroupName.text = "\((myGroups[indexPath.row]["members"] as? NSDictionary)?.count ?? 0) People"
        
        cell.cvPeople?.reloadData()
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? MyGroupTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? MyGroupTableViewCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("TableView view selected index path \(indexPath)")
    }
}

extension MyGroupVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (myGroups[collectionView.tag]["members"] as? NSDictionary)?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:GroupPeopleCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GroupPeopleCollectionViewCell
        
        cell.imgUser?.setCornerRadious(cell.imgUser.frame.width/2)
        cell.imgUser?.setBorder(0.5, color: UIColor.lightGrayColor())
        //cell.backgroundColor = model[collectionView.tag][indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}
