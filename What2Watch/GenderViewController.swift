//
//  GenderViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/28/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import ActionSheetPicker_3_0
import Firebase

class GenderViewController: BaseViewController {
    
    
    @IBOutlet var male: UILabel!
    @IBOutlet var female: UILabel!
    @IBOutlet var nationality: UILabel!
    @IBOutlet var nationalityButton: UIButton!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    var genderArray = ["Male", "Female"]
    
    override func viewDidLoad() {
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        male.hidden = true
        female.hidden = true
        nationality.hidden = true
        //self.saveData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.background.fadeOut(completion: {
            (finished: Bool) -> Void in
            self.background.fadeIn()
        })
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func maleButton(sender: AnyObject) {
        male.hidden = false
        TermsViewController.sex = genderArray[0]
    }
    
    @IBAction func femaleButton(sender: AnyObject) {
        female.hidden = false
        TermsViewController.sex = genderArray[1]
    }
    
    @IBAction func selectNationalityButton(sender: AnyObject) {
        ActionSheetStringPicker.showPickerWithTitle("Where Are You From?", rows: ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua & Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia & Herzegovina", "Botswana", "Brazil", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Costa Rica", "Côte D'Ivoire", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Demorcratic People's Republic of Korea", "Democratic Republic of the Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Savador", "Equatorial Guinea", "Eritrea", "Estonia", "Ehiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Republic of Korea", "Republic of Moldova", "Romania", "Russian Federation", "Rwanda", "Saint Kitts & Nevis", "Saint Lucia", "Saint Vincent & the Grenadines", "Samoa", "San Marino", "Sao Tome & Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Taiwan", "Tajikistan", "Thailand", "The former Yugoslav Republic of Macedonia", "Timor-Leste", "Togo", "Tonga", "Trinidad & Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom of Great Britian & Northern Ireland", "United Republic of Tanzania", "United States of America", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela, Bolivarian Republic of", "Viet Nam", "Yemen", "Zambia", "Zimbabwe"], initialSelection: 187, doneBlock: {
            
            picker, value, index in
            
            print("value = \(value)")
            print("index = \(index)")
            print("picker = \(picker)")
            self.nationality.text = ("\(index)")
            self.nationality.hidden = false
            self.nationalityButton.hidden = true
            //self.nationalityButton.setTitle("\(index)", forState: UIControlState.Normal)
            TermsViewController.origin = self.nationality.text!

            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func backButton(sender: AnyObject) {
         self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
}
