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
    private var locations: [Location]
    
    init(){
        //Set up the fileManager to be equal to the shared FileManager object
        fileManager = FileManager.default
        //Initilation the URL for where to store the location data
        //Functions defines the file storage to be in the user's home directory
        //Also, disables error propagation on the function.
        documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        //Initiaalize locations as empty
        locations = []
    }
}
