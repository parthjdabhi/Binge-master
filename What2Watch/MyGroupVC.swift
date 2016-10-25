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
import SWRevealViewController
import UIActivityIndicator_for_SDWebImage


class MyGroupVC: UIViewController, UITabBarDelegate, UITableViewDataSource {

    // MARK: - VC Outlets
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnByYourself: UIButton!
    @IBOutlet var btnByFriends: UIButton!
    @IBOutlet var tblGroupList: UITableView!
    
    // MARK: - VC Properties
    let model = generateRandomData()
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
    
    
    // MARK: - Delegates & DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:MyGroupTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)  as! MyGroupTableViewCell
        
        cell.imgGroup?.setCornerRadious(cell.imgGroup.frame.width/2)
        cell.imgGroup?.setBorder(1, color: UIColor.lightGrayColor())
        
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
        return model[collectionView.tag].count
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
