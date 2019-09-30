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

//A class to create custom pins on the map
class CustomPin: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(location: CLLocationCoordinate2D, pinTitle: String, pinSubtitle: String){
        coordinate = location
        title = pinTitle
        subtitle = pinSubtitle
    }
}

class MapViewController: UIViewController {
    var businesses: BusinessInfo = BusinessInfo(total: nil, businesses: [], region: nil)
    
    
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
        //Set lat and long to users current location
        let latitude = mapView.userLocation.coordinate.latitude
        let longitude = mapView.userLocation.coordinate.longitude
        let apikey = yelpAPIKey
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?term=food&latitude=\(latitude)&longitude=\(longitude)")
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        //Get JSON from Yelp API
        let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
            guard let yelpData = data,
                error == nil else{
                    print(error?.localizedDescription ?? "Response Error")
                    return
            }
            do{
                //Decode the recieved JSON into a BusinessInfo struct
                let result = try JSONDecoder().decode(BusinessInfo.self, from: yelpData)
                self.businesses = result
                //Find the closest restaurant
                let closestBusiness: BusinessInfo.Business = findClosestBusiness(self.businesses)
                let location = CLLocationCoordinate2D(latitude: (closestBusiness.coordinates?.latitude)!, longitude: (closestBusiness.coordinates?.longitude)!)
                let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                //Set the map to show the users location and make a pin for the closest restaurant
                self.mapView.showsUserLocation = true;
                self.mapView.setRegion(region, animated: true)
                let businessPin = CustomPin(location: location, pinTitle: (closestBusiness.name)!, pinSubtitle: "\((closestBusiness.location?.address1)!)\n\((closestBusiness.location?.city)!), \((closestBusiness.location?.state)!)")
                self.mapView.addAnnotation(businessPin)
            } catch let parsingError as NSError{
                print("Error", parsingError)
            }
        }
        task.resume()
    }
}

