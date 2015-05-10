//
//  ApartmentModel.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import Foundation
import CoreLocation

class ApartmentModel {
    
    static let basicInformationArray = ["Address", "Description", "Total Price", "Order Price", "Broker Fee", "How Many Bedrooms", "How Many Bathrooms", "How Many Living Rooms", "Which Floor", "Application Fee"]
    static let apartmentAmenitiesArray = ["Electricity Fee Included", "Water Fee Included", "Gas Fee Included", "Dish Washer", "Microwave", "Oven", "Air Conditioner", "Washing Machine", "Dryer", "Heater", "Furniture"]
    static let buildingFacilitiesArray = ["Doorman", "Gym", "Laundry Room", "Elevator", "Swimming Pool", "Parking"]
    
    let dateFormatter = NSDateFormatter()

    var basicInformationDict = [String: String]()
    var apartmentAmenitiesDict = [String: Bool]()
    var buildingFacilitiesDict = [String: Bool]()

    var additionalInfo1 = ""
    var additionalInfo2 = ""
    
    var imageUrls = [String?]()
    var moveinDate = NSDate()
    var coordinate: [Double]?
    
    let api = APIModel.sharedInstance
    let geoCoder = CLGeocoder()
    
    var requestData: NSDictionary? {
        var dict = NSMutableDictionary()
        let totalPrice = basicInformationDict["Total Price"]?.toInt()
        let orderPrice = basicInformationDict["Order Price"]?.toInt()
        let brokerFee = basicInformationDict["Broker Fee"]?.toInt()
        let bedrooms = basicInformationDict["How Many Bedrooms"]?.toInt()
        let bathrooms = basicInformationDict["How Many Bathrooms"]?.toInt()
        let livingrooms = basicInformationDict["How Many Living Rooms"]?.toInt()
        let floor = basicInformationDict["Which Floor"]?.toInt()
        let applicationFee = basicInformationDict["Broker Fee"]?.toInt()
        
        if totalPrice == nil || orderPrice == nil || brokerFee == nil || bedrooms == nil || bathrooms == nil || livingrooms == nil || floor == nil || applicationFee == nil {
            return nil
        }
        
        dict["totalPrice"] = totalPrice!
        dict["orderPrice"] = orderPrice!
        dict["addressDescription"] = basicInformationDict["Address"]
        dict["city"] = "New York, NY, United States"
        dict["gist"] = basicInformationDict["Description"]
        dict["elevator"] = buildingFacilitiesDict["Elevator"]
        dict["brokerFee"] = brokerFee!
        dict["beds"] = bedrooms!
        dict["bath"] = bathrooms!
        dict["livingroom"] = livingrooms!
        dict["floor"] = floor!
        dict["images"] = convertImages(imageUrls)
        dict["applicationFee"] = applicationFee!
        dict["moveinDate"] = dateFormatter.stringFromDate(moveinDate)
        dict["waterelecIncluded"] = apartmentAmenitiesDict["Water Fee Included"]
        dict["dishwasher"] = apartmentAmenitiesDict["Dish Washer"]
        dict["microwave"] = apartmentAmenitiesDict["Microwave"]
        dict["airconditioner"] = apartmentAmenitiesDict["Air Conditioner"]
        dict["heater"] = apartmentAmenitiesDict["Heater"]
        dict["dryer"] = apartmentAmenitiesDict["Dryer"]
        dict["furniture"] = apartmentAmenitiesDict["Furniture"]
        dict["sublease"] = false
        dict["shortTermLease"] = false
        dict["oven"] = apartmentAmenitiesDict["Oven"]
        dict["washingMachine"] = apartmentAmenitiesDict["Washing Machine"]
        dict["laundryRoom"] = buildingFacilitiesDict["Laundry Room"]
        dict["doorman"] = buildingFacilitiesDict["Doorman"]
        dict["gym"] = buildingFacilitiesDict["Gym"]
        dict["swimmingpool"] = buildingFacilitiesDict["Swimming Pool"]
        dict["parking"] = buildingFacilitiesDict["Parking"]
        dict["additionalInfo1"] = additionalInfo1
        dict["additionalInfo2"] = additionalInfo2
        dict["coordinates"] = coordinate
//        dict["qrcode"] =
//        dict["videos"] = 
//        dict["status"] =
//        dict["applicationDoc"] =
        
        return dict
    }
    
    
    var isComplete: Bool {
        // at least 8 images
        if imageUrls.count < 8 {
            return false
        }
        for url in imageUrls {
            if url == nil {
                return false
            }
        }
        // text fileds shoud be filled out
        for (index, value) in basicInformationDict {
            if value.isEmpty {
                return false
            }
        }
        
        return true
    }
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        for item in ApartmentModel.basicInformationArray {
            basicInformationDict[item] = ""
        }
        for item in ApartmentModel.apartmentAmenitiesArray {
            apartmentAmenitiesDict[item] = false
        }
        for item in ApartmentModel.buildingFacilitiesArray {
            buildingFacilitiesDict[item] = false
        }
    }
    
    func submit(success: NSDictionary -> Void, fail: NSError -> Void) {
        let address = basicInformationDict["Address"]!
        geoCoder.geocodeAddressString("\(address), New York", completionHandler: {
            (placemarks: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                return fail(NSError(domain: "coordinate retreive", code: 1000, userInfo: nil))
            }
            if let placemark = placemarks[0] as? CLPlacemark {
                let location = placemark.location.coordinate
                self.coordinate = [location.latitude, location.longitude]
                if let data = self.requestData {
                    self.api.addApartment(data, success: success, fail: fail)
                }
                else {
                    fail(NSError(domain: "number conversion", code: 1001, userInfo: nil))
                }
            }
            else {
                fail(NSError(domain: "coordinate retreive", code: 1000, userInfo: nil))

            }
        })
    }
    
    func convertImages(images: [String?]) -> [String] {
        var urls = [String]()
        for url in images {
            urls.append(url!)
        }
        return urls
    }
    func getBasicInformationAtIndex(index: Int) -> String {
        if index < 0 || index >= ApartmentModel.basicInformationArray.count {
            return ""
        }
        return basicInformationDict[ApartmentModel.basicInformationArray[index]]!
    }
    func getApartmentAmenitiesAtIndex(index: Int) -> Bool {
        if index < 0 || index >= ApartmentModel.apartmentAmenitiesArray.count {
            return false
        }
        return apartmentAmenitiesDict[ApartmentModel.apartmentAmenitiesArray[index]]!
    }
    func getBuildingFacilitiesAtIndex(index: Int) -> Bool {
        if index < 0 || index >= ApartmentModel.buildingFacilitiesArray.count {
            return false
        }
        return buildingFacilitiesDict[ApartmentModel.buildingFacilitiesArray[index]]!
    }
    func setBasicInformationAtIndex(index: Int, value: String) {
        if index < 0 || index >= ApartmentModel.basicInformationArray.count {
            return
        }
        basicInformationDict[ApartmentModel.basicInformationArray[index]] = value
    }
    func setApartmentAmenitiesAtIndex(index: Int, value: Bool) {
        if index < 0 || index >= ApartmentModel.apartmentAmenitiesArray.count {
            return
        }
        apartmentAmenitiesDict[ApartmentModel.apartmentAmenitiesArray[index]] = value
    }
    func setBuildingFacilitiesAtIndex(index: Int, value: Bool) {
        if index < 0 || index >= ApartmentModel.buildingFacilitiesArray.count {
            return
        }
        buildingFacilitiesDict[ApartmentModel.buildingFacilitiesArray[index]] = value
    }
}