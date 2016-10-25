//
//  BarSearchController.swift
//  Drinkr
//
//  Created by iParth on 10/24/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol searchDelegate {
    func onItemSelected(bar: Dictionary<String,AnyObject>)
}

class searchController: UITableViewController {

    var searchResults: [Dictionary<String,AnyObject>]!
    var delegate: searchDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResults = Array()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        //self.tableView.registerNib(UINib(nibName: "BarTableViewCell", bundle: nil), forCellReuseIdentifier: "BarTableViewCell")
        self.tableView.rowHeight = 44
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath)
        //userFirstName,userLastName,email
        cell.textLabel?.text = "\((self.searchResults[indexPath.row]["userFirstName"] as? String ?? "")!) \((self.searchResults[indexPath.row]["userLastName"] as? String ?? "")!) - \((self.searchResults[indexPath.row]["email"] as? String ?? "")!)"
        return cell
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("BarTableViewCell", forIndexPath: indexPath) as! BarTableViewCell
        //cell.Bar = self.searchResults[indexPath.row]
        //return cell
    }

    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {
            // 1
            self.dismissViewControllerAnimated(true, completion: nil)
        
        delegate.onItemSelected(searchResults[indexPath.row])
            // 2
//            let correctedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
//            let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false")
//            
//            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
//                // 3
//                do {
//                    if data != nil {
//                        let dic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
//                        let lat = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lat")?.objectAtIndex(0) as! Double
//                        let lon = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lng")?.objectAtIndex(0) as! Double
//                        // 4
//                        self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row])
//                    }
//                 
//                }catch {
//                    print("Error")
//                }
//            }
//            // 5
//            task.resume()
    }
    
    
    func reloadDataWithArray(array:[Dictionary<String,AnyObject>]){
        self.searchResults = array
        self.tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
