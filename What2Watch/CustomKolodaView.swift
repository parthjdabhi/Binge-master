//
//  CustomKolodaView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

let defaultBottomOffset:CGFloat = 0
let defaultTopOffset:CGFloat = 20
let defaultHorizontalOffset:CGFloat = 10
let defaultHeightRatio:CGFloat = 1.56
let backgroundCardHorizontalMarginMultiplier:CGFloat = 0.25
let backgroundCardScalePercent:CGFloat = 1.5

class CustomKolodaView: KolodaView {

    override func frameForCardAtIndex(index: UInt) -> CGRect {
        self.layoutIfNeeded()
        
        if index == 0 {
            let topOffset:CGFloat = defaultTopOffset
            let xOffset:CGFloat = defaultHorizontalOffset
            let width = CGRectGetWidth(self.frame ) - 2 * defaultHorizontalOffset
            let height = width * defaultHeightRatio
            let yOffset:CGFloat = topOffset
            //let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            
            let customFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width , height: UIScreen.mainScreen().bounds.height-69 )
            return customFrame
        } else if index == 1 {
            let horizontalMargin = -self.bounds.width * backgroundCardHorizontalMarginMultiplier
            let width = self.bounds.width * backgroundCardScalePercent
            let height = width * defaultHeightRatio
            
//            self.alpha
            
            //let frame = CGRect(x: horizontalMargin, y: 0, width: width, height: height)
            return CGRect(x: horizontalMargin, y: 0, width: width, height: height)
            
            //let customFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width , height: UIScreen.mainScreen().bounds.height-68 )
            //return customFrame
        }
        return CGRectZero
    }

}
