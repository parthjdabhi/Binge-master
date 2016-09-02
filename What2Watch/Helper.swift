//
//  Helper.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase

class MeasurementHelper: NSObject {
    
    static func sendLoginEvent() {
        FIRAnalytics.logEventWithName(kFIREventLogin, parameters: nil)
    }
    
    static func sendLogoutEvent() {
        FIRAnalytics.logEventWithName("logout", parameters: nil)
    }
    
    static func sendMessageEvent() {
        FIRAnalytics.logEventWithName("message", parameters: nil)
    }
}
