//
//  BusinessInfo.swift
//  Midterm1
//
//  Created by Jonathan Moore on 9/29/19.
//  Copyright © 2019 Jonathan Moore. All rights reserved.
//

import Foundation

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
