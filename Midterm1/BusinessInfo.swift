//
//  BusinessInfo.swift
//  Midterm1
//
//  Created by Jonathan Moore on 9/29/19.
//  Copyright © 2019 Jonathan Moore. All rights reserved.
//

import Foundation

//let yelpAPIKey = "6ffo9ft5YFWBCrVgiT76c516QE5RuxavdCvr-7o_oFD_kl5O9fZDNidhe0j7E7shxjrZimQlmkNJHuBOOR-Ic5ouF2-l9Be36RyfyuNEGuCZbquWa--8JNEAN9-PXXYx"

struct BusinessInfo: Codable {
    let total: Int?
    let businesses: [Business?]
    
    struct Business: Codable{
        let alias: String?
        let categories: [Category?]
        let coordinates: Coordinates?
        let display_phone: String?
        let distance: Double?
        let id: String?
        let image_url: String?
        let is_closed: Bool?
        let location: Location?
        let name: String?
        let phone: String?
        let price: String?
        let rating: Double?
        let review_count: Int?
        let transactions: [String?]
        let url: String?
        
        struct Category: Codable{
            let alias: String?
            let title: String?
        }
        
        struct Coordinates: Codable {
            let latitude: Double?
            let longitude: Double?
        }
        
        struct Location: Codable {
            let address1: String?
            let address2: String?
            let address3: String?
            let city: String?
            let country: String?
            let display_address: [String?]
            let state: String?
            let zip_code: String?
        }
    }
    
    struct Region: Codable{
        let center: Center?
        struct Center: Codable{
            let latitude: Double?
            let longitude: Double?
        }
    }
    
    let region: Region?
}

func findClosestBusiness(_ info: BusinessInfo) -> BusinessInfo.Business {
    var closestBusiness: BusinessInfo.Business
    closestBusiness = info.businesses[0]! //Set the closest business as the first one to start
    for business in info.businesses {
        if (business?.distance)! < closestBusiness.distance!{
            closestBusiness = business!
        }
    }
    return closestBusiness
}
/*
func getBusinessInfo(_ latitude: Double, longitude: Double) -> Any {
    let apikey = yelpAPIKey
    var result = BusinessInfo(total: 0, businesses: [], region: nil)
    let url = URL(string: "https://api.yelp.com/v3/businesses/search?term=food&latitude=\(latitude)&longitude=\(longitude)")
    var request = URLRequest(url: url!)
    request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"
    let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
        guard let yelpData = data,
            error == nil else{
                print(error?.localizedDescription ?? "Response Error")
                return
        }
        do{
            result = try JSONDecoder().decode(BusinessInfo.self, from: yelpData)
            /*
            if let jsonData = try JSONSerialization.jsonObject(with: yelpData, options: []) as? [String:Any]{
                let jsonDecoder = JSONDecoder()
                let businesses = try? jsonDecoder.decode(Array<BusinessInfo>.self, from: jsonData)
            }
            */
        } catch let parsingError as NSError{
            print("Error", parsingError)
        }
    }
    task.resume()
}
 */
