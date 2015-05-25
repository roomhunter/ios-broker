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
    case OffShelves
    case UnderReview
    case SoldOut
}
class ApartmentProfileItem {
    var thumbnail: NSURL
    var address: String
    var price: Int
    var status: ApartmentStatus
    var id: String
    
    var priceString: String {
        return "$\(price) / per month"
    }
    
    init(thumbnail: String, address: String, price: Int, status: Int, id: String) {
        
        self.thumbnail = NSURL(string: thumbnail)!
        self.address = address
        self.price = price
        self.id = id
        if status >= 0 && status <= 3 {
            self.status = ApartmentStatus(rawValue: status)!
        }
        else {
            self.status = ApartmentStatus(rawValue: 1)!
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
                let id = rawItem["aptId"] as? String
                if thumbnail != nil && address != nil && price != nil && status != nil && id != nil {
                    let newItem = ApartmentProfileItem(thumbnail: thumbnail!, address: address!, price: price!, status: status!, id: id!)
                    apartments.append(newItem)
                }
            }
        }
        return apartments
    }
}