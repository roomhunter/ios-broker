//
//  BrokerModel.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import Foundation

class BrokerModel {
//    var email = ""
    var token: String? {
        get {
            let userDefault = NSUserDefaults.standardUserDefaults()
            let token = userDefault.stringForKey("token")
            return token
        }
    }
    
    static let sharedInstance = BrokerModel()
    private init() {
        
    }
    
    func update(email: String, token: String) {
//        self.email = email
//        self.token = token
        // store to file system
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(token, forKey: "token")
    }
    
}
