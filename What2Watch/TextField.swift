//
//  TextField.swift
//  What2Watch
//
//  Created by MacBook Pro on 20/07/2016.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class TextField: UITextField {

    
        let inset: CGFloat = 30
        
        // placeholder position
        override func textRectForBounds(bounds: CGRect) -> CGRect {
            return CGRectInset(bounds , inset , inset)
        }
        
        // text position
        override func editingRectForBounds(bounds: CGRect) -> CGRect {
            
            //CGRect rect = [super editingRectForBounds:bounds];
            //UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 0);
            
            //return UIEdgeInsetsInsetRect(rect, insets);
            let rect=super.editingRectForBounds(bounds)
            let insets=UIEdgeInsets(top:-30, left: 0, bottom: 40, right: 0)
            return UIEdgeInsetsInsetRect(rect, insets)
            //return CGRectInset(bounds , inset , inset)
        }
        
        override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
            return CGRectInset(bounds, inset, inset) 
        }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
