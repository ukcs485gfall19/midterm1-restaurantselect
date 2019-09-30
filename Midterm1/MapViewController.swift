//
//  MapViewController.swift
//  Midterm1
//
//  Created by Jonathan Moore on 9/24/19.
//  Copyright © 2019 Jonathan Moore. All rights reserved.
//

import UIKit
import MapKit
let yelpAPIKey = "6ffo9ft5YFWBCrVgiT76c516QE5RuxavdCvr-7o_oFD_kl5O9fZDNidhe0j7E7shxjrZimQlmkNJHuBOOR-Ic5ouF2-l9Be36RyfyuNEGuCZbquWa--8JNEAN9-PXXYx"

class MapViewController: UIViewController {
    let latitude: Double = 37.8844
    let longitude: Double = -84.6135
    var businesses: BusinessInfo = BusinessInfo(total: nil, businesses: [], region: nil)
    //let latitude = LocationStorage.shared.locations.last?.latitude //Replace later with current location
    //let longitude = LocationStorage.shared.locations.last?.longitude
    
    @IBOutlet weak var mapView: MKMapView! //Links the MKMapView into the storyboard
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    @IBAction func AddLocation(_ sender: Any) {
        
        // save current location
        guard let currentLocation = mapView.userLocation.location else {
            return
        }
        
        LocationStorage.shared.saveCLLocationToDisk(currentLocation)
    }
    
    @IBAction func findFood(_ sender: UIBarButtonItem) {
        let apikey = yelpAPIKey
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
                let result = try JSONDecoder().decode(BusinessInfo.self, from: yelpData)
                self.businesses = result
                print(self.businesses)
            } catch let parsingError as NSError{
                print("Error", parsingError)
            }
        }
        task.resume()
    }
}

