//
//  BaseViewController.swift
//  What2Watch
//
//  Created by Mobile Developer on 8/2/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

protocol BaseViewControllerDelegate {
    func hiddenPageController()
    func showPageController()
}

class BaseViewController: UIViewController {

    @IBOutlet var background: UIView!
    var delegate: BaseViewControllerDelegate!
    
    var goNextSelectorClosure: Optional<() -> ()> = nil
    var goPrevSelectorClosure: Optional<() -> ()> = nil
    var goBackSelectorClosure: Optional<() -> ()> = nil
    
    //var Base:UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        goBackSelectorClosure = {
//            self.navigationController?.popViewControllerAnimated(true)
//        }
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

}
