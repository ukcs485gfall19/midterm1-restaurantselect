//
//  Location.swift
//  Midterm1
//
//  Created by Jonathan Moore on 9/24/19.
//  Copyright © 2019 Jonathan Moore. All rights reserved.
//

import Foundation
import CoreLocation

 /*
 Borrowed code from https://stackoverflow.com/questions/49388372/codable-extension-to-corelocation-classes
 to make CLLocationCoordinate2D codable.
 */
extension CLLocationCoordinate2D: Codable {
    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
    }
}

class Location: Codable{
    let latitude: Double
    let longitude: Double
    let date: Date
    let dateString: String
    let description: String
    var coordinates: CLLocationCoordinate2D
    //Create a formatter to allow conversion from CLLocationCoordinate2D to String.
    static let dateFormatter: DateFormatter = {() -> DateFormatter in
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        return df
    }()
        
    init(_ initialCoordinates: CLLocationCoordinate2D, initialDate: Date, locationDescription: String){
        latitude = initialCoordinates.latitude
        longitude = initialCoordinates.longitude
        coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        date = initialDate
        dateString = Location.dateFormatter.string(from: initialDate)
        description = locationDescription
    }
    
    convenience init(visit: CLVisit, descriptionString: String) {
        self.init(visit.coordinate, initialDate: visit.arrivalDate, locationDescription: descriptionString)
    }
}
