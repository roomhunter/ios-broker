//
//  BrokerModel.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import Foundation

class BrokerModel {
    var token: String? {
        get {
            let userDefault = NSUserDefaults.standardUserDefaults()
            let token = userDefault.stringForKey("token")
            return token
        }
    }
    var email: String? {
        get {
            let userDefault = NSUserDefaults.standardUserDefaults()
            let email = userDefault.stringForKey("email")
            return email
        }
    }
    
    static let sharedInstance = BrokerModel()
    private init() {
        
    }
    
    func update(email: String, token: String) {
        // store to file system
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(token, forKey: "token")
        userDefault.setObject(email, forKey: "email")
    }
    
}
