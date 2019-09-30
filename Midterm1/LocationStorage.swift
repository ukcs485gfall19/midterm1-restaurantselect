//
//  LocationStorage.swift
//  Midterm1
//
//  Created by Jonathan Moore on 9/24/19.
//  Copyright © 2019 Jonathan Moore. All rights reserved.
//
import Foundation
import CoreLocation

class LocationStorage {
    //Make singleton for usage in app
    static let shared = LocationStorage()
    
    private let fileManager: FileManager
    private let documentsURL: URL
    var locations: [Location]
    
    init(){
        //Set up the fileManager to be equal to the shared FileManager object
        fileManager = FileManager.default
        //Initilation the URL for where to store the location data
        //Functions defines the file storage to be in the user's home directory
        //Also, disables error propagation on the function.
        documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        //Initialize locations as empty
        let jsonDecoder = JSONDecoder()
        
        // get URLs for all files in the Documents folder
        let locationFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        locations = locationFilesURLs.compactMap { url -> Location? in
            
            // skip .DS_Store
            guard !url.absoluteString.contains(".DS_Store") else {
                return nil
            }
            
            // read data from file
            guard let data = try? Data(contentsOf: url) else {
                return nil
            }
            
            // decode raw data in Location objects
            return try? jsonDecoder.decode(Location.self, from: data)
            
            // sort locations by date
        }.sorted(by: {$0.date < $1.date })
        
    }
    
    func saveLocationOnDisk(_ location: Location) {
        
        // creates a JSON encoder
        let encoder = JSONEncoder()
        let timestamp = location.date.timeIntervalSince1970
        
        // gets the URL to the file, data timestamp as file name
        let fileURL = documentsURL.appendingPathComponent("\(timestamp)")
        
        // converts location object to raw data (assumes successful conversion)
        let data = try! encoder.encode(location)
        
        // writes data to file (assumes successful write)
        try! data.write(to: fileURL)
        
        // add saved location to local array
        locations.append(location)
        
        NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: ["location": location])
    }
    
    func saveCLLocationToDisk(_ clLocation: CLLocation) {
        let currentDate = Date()
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) {
        placemarks, _ in
            if let place = placemarks?.first {
                
                let location = Location(clLocation.coordinate, initialDate: currentDate, locationDescription: "\(place)")
                
                self.saveLocationOnDisk(location)
            }
        }
    }
}

    extension Notification.Name {
        static let newLocationSaved = Notification.Name("newLocationSaved")
    }
