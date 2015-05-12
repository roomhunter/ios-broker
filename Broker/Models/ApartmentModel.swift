//
//  ApartmentModel.swift
//  agent
//
//  Created by to0 on 5/7/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import Foundation
import CoreLocation

enum ApartmentAddressInputMode: Int {
    case Manually
    case Auto
}

enum ApartmentInformationState: Int {
    case AddressIncorrect
    case Incomplete
    case ShouldBeNumbers
    case Ready
}

enum ApartmentMediaState: Int {
    case NotEnough
    case TooMany
    case Ready
    case Loading
}

class ApartmentModel {
    
    static let basicInformationArray = ["Description", "Total Price", "Order Price", "Broker Fee (%)", "How Many Bedrooms", "How Many Bathrooms", "How Many Living Rooms", "Which Floor", "Application Fee"]
    static let apartmentAmenitiesArray = ["Electricity Fee Included", "Water Fee Included", "Gas Fee Included", "Dish Washer", "Microwave", "Oven", "Air Conditioner", "Washing Machine", "Dryer", "Heater", "Furniture"]
    static let buildingFacilitiesArray = ["Doorman", "Gym", "Laundry Room", "Elevator", "Swimming Pool", "Parking"]
    static let additionalInfoArray = ["Additional Info for room amenities", "Additional Info for building facilities"]
    
    let dateFormatter = NSDateFormatter()

    var basicInformationDict = [String: String]()
    var apartmentAmenitiesDict = [String: Bool]()
    var buildingFacilitiesDict = [String: Bool]()
    var additionalInfoDict = [String: String]()
    
    var addressLine1: String?
    var apartmentNumberString: String?
    var cityCountryString: String = "New York"
    
    var imageUrls = [String?]()
    var moveinDate = NSDate()
    var coordinate: [Double]?
    
    let api = APIModel.sharedInstance
    let geoCoder = CLGeocoder()
    
    var uploadRequests = [AWSS3TransferManagerUploadRequest?]()
    var imageThumbnails = [UIImage]()
    
    var moveinDateString: String {
        return dateFormatter.stringFromDate(moveinDate)
    }
    var requestData: NSDictionary {
        var dict = NSMutableDictionary()
        dict["totalPrice"] = basicInformationDict["Total Price"]!.toInt()
        dict["orderPrice"] = basicInformationDict["Order Price"]!.toInt()
        
        if let numberString = apartmentNumberString?.stringByReplacingOccurrencesOfString("apt", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil) {
            dict["addressDescription"] = "\(addressLine1!), Apt \(numberString)"
        }
        else {
            dict["addressDescription"] = addressLine1!
        }
        dict["city"] = cityCountryString
        dict["gist"] = basicInformationDict["Description"]
        dict["elevator"] = buildingFacilitiesDict["Elevator"]
        dict["brokerFee"] = basicInformationDict["Broker Fee (%)"]!.toInt()
        dict["beds"] = basicInformationDict["How Many Bedrooms"]!.toInt()
        dict["bath"] = basicInformationDict["How Many Bathrooms"]!.toInt()
        dict["livingroom"] = basicInformationDict["How Many Living Rooms"]!.toInt()
        dict["floor"] = basicInformationDict["Which Floor"]!.toInt()
        dict["images"] = convertImages(imageUrls)
        dict["applicationFee"] = basicInformationDict["Application Fee"]!.toInt()!
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
        dict["additionalInfo1"] = additionalInfoDict[ApartmentModel.additionalInfoArray[0]]
        dict["additionalInfo2"] = additionalInfoDict[ApartmentModel.additionalInfoArray[1]]
        dict["coordinates"] = coordinate
//        dict["qrcode"] =
//        dict["videos"] = 
//        dict["status"] =
//        dict["applicationDoc"] =
        
        return dict
    }
    
    
    var informationState: ApartmentInformationState {
        // text fileds shoud be filled out
        if addressLine1 == nil {
            return .AddressIncorrect
        }
        
        for (index, value) in basicInformationDict {
            if value.isEmpty {
                return .Incomplete
            }
        }

        // check numbers
        let totalPrice = basicInformationDict["Total Price"]?.toInt()
        let orderPrice = basicInformationDict["Order Price"]?.toInt()
        let brokerFee = basicInformationDict["Broker Fee (%)"]?.toInt()
        let bedrooms = basicInformationDict["How Many Bedrooms"]?.toInt()
        let bathrooms = basicInformationDict["How Many Bathrooms"]?.toInt()
        let livingrooms = basicInformationDict["How Many Living Rooms"]?.toInt()
        let floor = basicInformationDict["Which Floor"]?.toInt()
        let applicationFee = basicInformationDict["Application Fee"]?.toInt()
        
        if totalPrice == nil || orderPrice == nil || brokerFee == nil || bedrooms == nil || bathrooms == nil || livingrooms == nil || floor == nil || applicationFee == nil {
            return .ShouldBeNumbers
        }
        
        return .Ready
    }
    
    var mediaState: ApartmentMediaState {
        // at least 8 images

        if imageUrls.count < 8 {
            return .NotEnough
        }
//        else if imageUrls.count > 16 {
//            return .TooMany
//        }
        for url in imageUrls {
            if url == nil {
                return .NotEnough
            }
        }
        return .Ready
    }
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for item in ApartmentModel.basicInformationArray {
            basicInformationDict[item] = ""
        }
        for item in ApartmentModel.apartmentAmenitiesArray {
            apartmentAmenitiesDict[item] = false
        }
        for item in ApartmentModel.buildingFacilitiesArray {
            buildingFacilitiesDict[item] = false
        }
        for item in ApartmentModel.additionalInfoArray {
            additionalInfoDict[item] = ""
        }
    }
    
    func convertAddressString(addressString: String, success: (Void -> Void)?) {
        geoCoder.geocodeAddressString("\(addressString), New York", completionHandler: {
            (placemarks: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                return
            }
            if let placemark = placemarks[0] as? CLPlacemark {
                let location = placemark.location
                let coordinate2D = location.coordinate
                self.cityCountryString = "\(placemark.subAdministrativeArea), \(placemark.administrativeArea) \(placemark.postalCode), \(placemark.ISOcountryCode)"
                self.coordinate = [coordinate2D.latitude, coordinate2D.longitude]
                self.addressLine1 = addressString
                success?()
            }
        })
    }
    
    func submit(success: NSDictionary -> Void, fail: NSError -> Void) {
        let data = requestData
        println(data)
        self.api.addApartment(data, success: success, fail: fail)
    }
    
    func convertImages(images: [String?]) -> [String] {
        var urls = [String]()
        for url in images {
            urls.append(url!)
        }
        return urls
    }
}