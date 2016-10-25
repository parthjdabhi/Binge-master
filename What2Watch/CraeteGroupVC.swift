//
//  CraeteGroupVC.swift
//  What2Watch
//
//  Created by iParth on 10/25/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class CraeteGroupVC: UIViewController {

    // MARK: - VC Outlets
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var imgGroup: UIImageView!
    @IBOutlet var btnaddMember: UIButton!
    @IBOutlet var lblMembersCount: UILabel!
    @IBOutlet var btnCreateGroup: UIButton!
    @IBOutlet weak var txtGroupName: UITextField!
    
    // MARK: - VC Properties
    
    
    // MARK: - VC Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    
    @IBAction func actionGoToBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func actionSelectGroupImage(sender: AnyObject) {
    }
    @IBAction func actionAddMember(sender: AnyObject) {
    }
    @IBAction func actionCreateGroup(sender: AnyObject) {
    }

    // MARK: - VC Methods
    
}
