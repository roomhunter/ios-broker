//
//  APIModel.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//
import Foundation

class APIModel {
    var session: NSURLSession
    let HOST = "https://api.roomhunter.us/v1"
//    let HOST = "http://test.roomhunter.us:3000/v1"
    
    static let sharedInstance = APIModel()
    
    private init() {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = ["Accept": "application/json"]
        session = NSURLSession(configuration: sessionConfiguration)
    }
    
    func loginWith(email: String, password: String, success: NSDictionary -> Void, fail: NSError -> Void) {
        let url: String
        let req = ["password": password, "email": email]
        let broker = BrokerModel.sharedInstance
        post("\(HOST)/users/login", data: req , success: success, fail: fail)
    }
    
    func verifyToken(token: String, success: NSDictionary -> Void, fail: NSError -> Void) {
        let req = ["userToken": token]
        post("\(HOST)/users/verify-token", data: req, success: success, fail: fail)
    }
    func addApartment(aptData: NSDictionary, success: NSDictionary -> Void, fail: NSError -> Void) {
        var data = NSMutableDictionary(dictionary: aptData)
        if let token = BrokerModel.sharedInstance.token {
            data["userToken"] = token
        }
        post("\(HOST)/brokers/apartment", data: data, success: success, fail: fail)
    }
    func getApartments(offset: Int, success: NSDictionary -> Void, fail: NSError -> Void) {
        let token = BrokerModel.sharedInstance.token
        if token == nil {
            fail(NSError(domain: "token invalid", code: 401, userInfo: nil))
            return
        }
        let path = "\(HOST)/brokers/apartments?userToken=\(token!)&pageOffset=\(offset)&pageLimit=10"
        get(path, success: success, fail: fail)
    }
    func removeApartment(id: String, success: NSDictionary -> Void, fail: NSError -> Void) {
        let token = BrokerModel.sharedInstance.token
        if token == nil {
            fail(NSError(domain: "token invalid", code: 401, userInfo: nil))
            return
        }
        let empty = NSDictionary()
        let path = "\(HOST)/brokers/apartmentOff/\(id)?userToken=\(token!)"
        post(path, data: empty, success: success, fail: fail)
    }
    
    // low-level requests
    private func get(path: String, success: (NSDictionary -> Void)?, fail: ((NSError) -> Void)? = nil) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string: path)
        
        let task = session.dataTaskWithURL(url!, completionHandler: {(data: NSData!, res: NSURLResponse!, err: NSError!) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if err != nil {
                fail?(err)
                return
            }
            var jsonErr: NSError?
            let jsonObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonErr)
            if jsonErr != nil {
                // Json Conversion Error
                println(NSString(data: data, encoding:NSUTF8StringEncoding))
                fail?(NSError(domain: "json conversion", code: 510, userInfo: nil))
                return
            }
            
            if let json = jsonObject as? NSDictionary  {
                success?(json)
                return
            }
        })
        
        task.resume()
    }
    
    private func post(path: String, data: NSDictionary, success: (NSDictionary -> Void)?, fail: ((NSError) -> Void)? = nil) {
        
        var reqJsonErr: NSError?
        let url = NSURL(string: path)
        let request = NSMutableURLRequest(URL: url!)
        let bodyData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.allZeros, error: &reqJsonErr)
        if reqJsonErr != nil {
            fail?(reqJsonErr!)
            return
        }
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = bodyData
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let task = session.dataTaskWithRequest(request, completionHandler: {(data: NSData!, res: NSURLResponse!, err: NSError!) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if err != nil {
                fail?(err)
                return
            }
            let httpRes = res as! NSHTTPURLResponse
            let statusCode = httpRes.statusCode
            if statusCode / 100 != 2 {
                let err = NSError(domain: "", code: statusCode, userInfo: nil)
                dispatch_async(dispatch_get_main_queue(), {
                    fail?(err)
                })
                return
            }
            var jsonErr: NSError?
            let jsonObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonErr)
            if jsonErr != nil {
                // Json Conversion Error
                println(NSString(data: data, encoding:NSUTF8StringEncoding))
                fail?(NSError(domain: "json conversion", code: 510, userInfo: nil))
                return
            }
            
            if let json = jsonObject as? NSDictionary  {
                success?(json)
                return
            }
        })
        
        task.resume()
    }
}
