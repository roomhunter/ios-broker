//
//  ApartmentProfileModel.swift
//  Broker
//
//  Created by to0 on 5/13/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import Foundation

enum ApartmentStatus: Int {
    case OnSale
    case SoldOut
    case UnderReview
}
class ApartmentProfileItem {
    var thumbnail: NSURL
    var address: String
    var price: Int
    var status: ApartmentStatus
    
    var priceString: String {
        return "$\(price) / per month"
    }
    
    init(thumbnail: String, address: String, price: Int, status: Int) {
        
        self.thumbnail = NSURL(string: thumbnail)!
        self.address = address
        self.price = price
        if status >= 0 && status <= 2 {
            self.status = ApartmentStatus(rawValue: status)!
        }
        else {
            self.status = ApartmentStatus(rawValue: 2)!
        }
    }
}
class ApartmentProfileList {
    var data = [ApartmentProfileItem]()
    let api = APIModel.sharedInstance
    
    func refreshData(success: Void -> Void) {
        api.getApartments(1, success: { [unowned self](res: NSDictionary) in
            self.data = self.apartmentsFromJson(res)
            success()
            }, fail: { (err: NSError) in
                
        })
    }
    
    func apartmentsFromJson(jsonObject: NSDictionary) -> [ApartmentProfileItem] {
        var apartments = [ApartmentProfileItem]()
        if let rawItems = (jsonObject["data"] as? NSDictionary)?["list"] as? [NSDictionary] {
            for rawItem in rawItems {
                let thumbnail = (rawItem["images"] as? [String])?[0]
                let address = rawItem["addressDescription"] as? String
                let price = rawItem["totalPrice"] as? Int
                let status = rawItem["status"] as? Int
                if thumbnail != nil && address != nil && price != nil && status != nil{
                    let newItem = ApartmentProfileItem(thumbnail: thumbnail!, address: address!, price: price!, status: status!)
                    apartments.append(newItem)
                }
            }
        }
        return apartments
    }
}