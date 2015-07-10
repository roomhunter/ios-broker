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
    case SelectCover
    case Ready
    case Loading
    case Success
}

class ApartmentModel {
    
    static let basicInformationArray = ["Description", "Monthly Rental", "Broker Fee (%)", "How Many Bedrooms", "How Many Bathrooms", "How Many Living Rooms", "Which Floor", "Application Fee"]
    static let apartmentAmenitiesArray = ["Electricity Fee Included", "Water Fee Included", "Gas Fee Included", "Dish Washer", "Microwave", "Oven", "Air Conditioner", "Washing Machine and Dryer", "Heater", "Furniture"]
    static let buildingFacilitiesArray = ["Doorman", "Gym", "Laundry Room", "Elevator", "Swimming Pool", "Parking"]
    static let additionalInfoArray = ["Additional Info for room amenities", "Additional Info for building facilities"]
    
    let dateFormatter = NSDateFormatter()
    let api = APIModel.sharedInstance
    let geoCoder = CLGeocoder()

    var basicInformationDict = [String: String]()
    var apartmentAmenitiesDict = [String: Bool]()
    var buildingFacilitiesDict = [String: Bool]()
    var additionalInfoDict = [String: String]()
    var moveinDate = NSDate()
    var coordinate: [Double]?
    
    var addressLine1: String?
    var addressLine2: String?
    var cityCountryString = "New York"
    
    var videoUrls = [String?]()
    var videoUploadRequests = [AWSS3TransferManagerUploadRequest?]()
    var videoThumbnails = [UIImage]()
    var failedVideoRequests = [Int: Bool]()
    
    var coverIndex: Int?
    var uploadRequests = [AWSS3TransferManagerUploadRequest?]()
    var imageUrls = [String?]()
    var imageThumbnails = [UIImage]()
    var failedRequests = [Int: Bool]()
    
    var renewed = false
    
    var moveinDateString: String {
        return dateFormatter.stringFromDate(moveinDate)
    }
    var requestData: NSDictionary {
        var dict = NSMutableDictionary()
        // they are the same
        dict["totalPrice"] = basicInformationDict["Monthly Rental"]!.toInt()
        dict["orderPrice"] = basicInformationDict["Monthly Rental"]!.toInt()
        
        if let numberString = addressLine2?.stringByReplacingOccurrencesOfString("apt", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil) {
            if numberString.isEmpty {
                dict["addressDescription"] = addressLine1!.uppercaseString
            }
            else {
                dict["addressDescription"] = "\(addressLine1!), Apt \(numberString)".uppercaseString
            }
        }
        else {
            dict["addressDescription"] = addressLine1!.uppercaseString
        }
        dict["city"] = cityCountryString
        dict["gist"] = basicInformationDict["Description"]?.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.allZeros, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        dict["elevator"] = buildingFacilitiesDict["Elevator"]
        dict["brokerFee"] = basicInformationDict["Broker Fee (%)"]!.toInt()
        dict["beds"] = basicInformationDict["How Many Bedrooms"]!.toInt()
        dict["bath"] = NSNumberFormatter().numberFromString(basicInformationDict["How Many Bathrooms"]!)?.doubleValue
        dict["livingRoom"] = basicInformationDict["How Many Living Rooms"]!.toInt()
        dict["floor"] = basicInformationDict["Which Floor"]!.toInt()
        dict["images"] = convertImages(imageUrls)
        dict["applicationFee"] = basicInformationDict["Application Fee"]!.toInt()!
        dict["moveinDate"] = dateFormatter.stringFromDate(moveinDate)
        dict["waterFeeIncluded"] = apartmentAmenitiesDict["Water Fee Included"]
        dict["elecFeeIncluded"] = apartmentAmenitiesDict["Electricity Fee Included"]
        dict["gasFeeIncluded"] = apartmentAmenitiesDict["Gas Fee Included"]
        dict["dishWasher"] = apartmentAmenitiesDict["Dish Washer"]
        dict["microwave"] = apartmentAmenitiesDict["Microwave"]
        dict["airConditioner"] = apartmentAmenitiesDict["Air Conditioner"]
        dict["heater"] = apartmentAmenitiesDict["Heater"]
        // they are the same
        dict["washingMachine"] = apartmentAmenitiesDict["Washing Machine and Dryer"]
        
        dict["furniture"] = apartmentAmenitiesDict["Furniture"]
        dict["sublease"] = false
        dict["shortTermLease"] = false
        dict["oven"] = apartmentAmenitiesDict["Oven"]
        dict["laundryRoom"] = buildingFacilitiesDict["Laundry Room"]
        dict["doorman"] = buildingFacilitiesDict["Doorman"]
        dict["gym"] = buildingFacilitiesDict["Gym"]
        dict["swimmingPool"] = buildingFacilitiesDict["Swimming Pool"]
        dict["parking"] = buildingFacilitiesDict["Parking"]
        dict["additionalInfo1"] = additionalInfoDict[ApartmentModel.additionalInfoArray[0]]
        dict["additionalInfo2"] = additionalInfoDict[ApartmentModel.additionalInfoArray[1]]
        dict["coordinates"] = coordinate
        
        dict["videos"] = convertVideos(videoUrls)
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
        let totalPrice = basicInformationDict["Monthly Rental"]?.toInt()
        let brokerFee = basicInformationDict["Broker Fee (%)"]?.toInt()
        let bedrooms = basicInformationDict["How Many Bedrooms"]?.toInt()
        let bathrooms = NSNumberFormatter().numberFromString(basicInformationDict["How Many Bathrooms"]!)?.doubleValue
        let livingrooms = basicInformationDict["How Many Living Rooms"]?.toInt()
        let floor = basicInformationDict["Which Floor"]?.toInt()
        let applicationFee = basicInformationDict["Application Fee"]?.toInt()
        
        if totalPrice == nil || brokerFee == nil || bedrooms == nil || bathrooms == nil || livingrooms == nil || floor == nil || applicationFee == nil {
            return .ShouldBeNumbers
        }
        
        return .Ready
    }
    
    var mediaState: ApartmentMediaState {
        // at least 8 images

        if imageUrls.count < 4 {
            return .NotEnough
        }
        for (index, url) in enumerate(imageUrls)  {
            if url == nil && failedRequests[index] == nil {
                return .NotEnough
            }
        }
        if coverIndex == nil {
            return .SelectCover
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
    func renewApartment() {
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
        
        addressLine1 = nil
        addressLine2 = nil
        cityCountryString = "New York"
        
        moveinDate = NSDate()
        coordinate = nil
        coverIndex = nil
        
        videoUrls = []
        videoUploadRequests = []
        videoThumbnails = []
        failedVideoRequests = [Int: Bool]()

        
        imageUrls = []
        uploadRequests = []
        imageThumbnails = []
        failedRequests = [Int: Bool]()
        
        renewed = true
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
                self.coordinate = [coordinate2D.longitude, coordinate2D.latitude]
                self.addressLine1 = addressString.uppercaseString
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
        urls.append(images[coverIndex!]!)
        
        for (index, url) in enumerate(images) {
            if index != coverIndex! && failedRequests[index] == nil {
                urls.append(url!)
            }
        }
        return urls
    }
    
    func convertVideos(videos: [String?]) -> [String] {
        var urls = [String]()
        
        for (index, url) in enumerate(videos) {
            if failedVideoRequests[index] == nil {
                urls.append(url!)
            }
        }
        return urls

    }
}