//
//  ApartmentModel.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import Foundation

class Apartment {
    
    static let basicInformationArray = ["Address", "Description", "Total Price", "Order Price", "Broker Fee", "How Many Bedrooms", "How Many Bathrooms", "How Many Living Rooms", "Which Floor", "Application Fee"]
    static let apartmentAmenitiesArray = ["Electricity Fee Included", "Water Fee Included", "Gas Fee Included", "Dish Washer", "Microwave", "Oven", "Air Conditioner", "Washing Machine", "Dryer", "Heater", "Furniture"]
    static let buildingFacilitiesArray = ["Doorman", "Gym", "Laundry Room", "Elevator", "Swimming Pool", "Parking"]
    
    let dateFormatter = NSDateFormatter()

    var basicInformationDict = [String: String]()
    var apartmentAmenitiesDict = [String: Bool]()
    var buildingFacilitiesDict = [String: Bool]()

    var additionalInfo1 = ""
    var additionalInfo2 = ""
    
    var images = [String?]()
    var moveinDate = NSDate()
    
    let api = APIModel.sharedInstance
    
    var requestData: NSDictionary {
        var dict = NSMutableDictionary()
        
        dict["totalPrice"] = basicInformationDict["Total Price"]
        dict["orderPrice"] = basicInformationDict["Order Price"]
        dict["addressDescription"] = basicInformationDict["Address"]
        dict["city"] = "New York, NY, United States"
        dict["gist"] = basicInformationDict["Description"]
        dict["elevator"] = buildingFacilitiesDict["Elevator"]
        dict["brokerFee"] = basicInformationDict["Broker Fee"]
        dict["beds"] = basicInformationDict["How Many Bedrooms"]
        dict["bath"] = basicInformationDict["How Many Bathrooms"]
        dict["livingroom"] = basicInformationDict["How Many Living Rooms"]
        dict["floor"] = basicInformationDict["Which Floor"]
        dict["images"] = convertImages(images)
        dict["applicationFee"] = basicInformationDict["Broker Fee"]
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
        
//        dict["coordinates"] = 
//        dict["qrcode"] =
//        dict["videos"] = 
//        dict["status"] =
//        dict["applicationDoc"] =
        
        return dict
    }
    
    
    var isComplete: Bool {
        for url in images {
            if url == nil {
                return false
            }
        }
        for (index, value) in basicInformationDict {
            if value.isEmpty {
                return false
            }
        }
        
        return true
    }
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        for item in Apartment.basicInformationArray {
            basicInformationDict[item] = ""
        }
        for item in Apartment.apartmentAmenitiesArray {
            apartmentAmenitiesDict[item] = false
        }
        for item in Apartment.buildingFacilitiesArray {
            buildingFacilitiesDict[item] = false
        }
    }
    
    func submit(success: NSDictionary -> Void, fail: NSError -> Void) {
        println(requestData)
        api.addApartment(requestData, success: success, fail: fail)
    }
    
    func convertImages(images: [String?]) -> [String] {
        var urls = [String]()
        for url in images {
            urls.append(url!)
        }
        return urls
    }
    func getBasicInformationAtIndex(index: Int) -> String {
        if index < 0 || index >= Apartment.basicInformationArray.count {
            return ""
        }
        return basicInformationDict[Apartment.basicInformationArray[index]]!
    }
    func getApartmentAmenitiesAtIndex(index: Int) -> Bool {
        if index < 0 || index >= Apartment.apartmentAmenitiesArray.count {
            return false
        }
        return apartmentAmenitiesDict[Apartment.apartmentAmenitiesArray[index]]!
    }
    func getBuildingFacilitiesAtIndex(index: Int) -> Bool {
        if index < 0 || index >= Apartment.buildingFacilitiesArray.count {
            return false
        }
        return buildingFacilitiesDict[Apartment.buildingFacilitiesArray[index]]!
    }
    func setBasicInformationAtIndex(index: Int, value: String) {
        if index < 0 || index >= Apartment.basicInformationArray.count {
            return
        }
        basicInformationDict[Apartment.basicInformationArray[index]] = value
    }
    func setApartmentAmenitiesAtIndex(index: Int, value: Bool) {
        if index < 0 || index >= Apartment.apartmentAmenitiesArray.count {
            return
        }
        apartmentAmenitiesDict[Apartment.apartmentAmenitiesArray[index]] = value
    }
    func setBuildingFacilitiesAtIndex(index: Int, value: Bool) {
        if index < 0 || index >= Apartment.buildingFacilitiesArray.count {
            return
        }
        buildingFacilitiesDict[Apartment.buildingFacilitiesArray[index]] = value
    }
}