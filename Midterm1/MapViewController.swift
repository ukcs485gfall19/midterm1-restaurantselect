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
    
    //var categories: [Category?]
    var display_phone: String?
    var image_url: String?
    var price: String?
    var rating: Double?
    var review_count: Int?
    var url: String? // currently unused, will eventually launch app's website
    
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
        mapView.userTrackingMode = .follow
        
        mapView.delegate = self
        
        // generates pins from previous locations, adds to map
        let annotations = LocationStorage.shared.locations.map { annotationForLocation($0) }
        mapView.addAnnotations(annotations)
        
        // listens for when a new location is recorded
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(newLocationAdded(_:)),
        name: .newLocationSaved,
        object: nil)
    }
    
    @IBAction func GetDirections(_ sender: Any) {
        
        let lat: CLLocationDegrees = 37.9885
        let lng: CLLocationDegrees = 84.5284
        let currentLocationLatitude = mapView.userLocation.coordinate.latitude
        let currentLocationLongitude = mapView.userLocation.coordinate.longitude
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: currentLocationLatitude, longitude: currentLocationLongitude)))
        source.name = "Source"
        
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)))
        destination.name = "Destination"
        
        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
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
                let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                //Set the map to show the users location and make a pin for the closest restaurant
                self.mapView.showsUserLocation = true;
                self.mapView.setRegion(region, animated: true)
                let businessPin = CustomPin(location: location, pinTitle: (closestBusiness.name)!, pinSubtitle: "\((closestBusiness.location?.address1)!)\n\((closestBusiness.location?.city)!), \((closestBusiness.location?.state)!)")
                // add details of business pin
                businessPin.display_phone = closestBusiness.display_phone
                businessPin.image_url = closestBusiness.image_url
                businessPin.price = closestBusiness.price
                businessPin.rating = closestBusiness.rating
                businessPin.review_count = closestBusiness.review_count
                businessPin.url = closestBusiness.url
                // add new pin to map view
                self.mapView.addAnnotation(businessPin)
                
            } catch let parsingError as NSError{
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    // create a pin annotation with a title and coordinates
    func annotationForLocation(_ location: Location) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = location.dateString
        annotation.coordinate = location.coordinates
        return annotation
    }

    // add a pin when a new location is logged
    @objc func newLocationAdded(_ notification: Notification) {
        guard let location = notification.userInfo?["location"] as?
            Location else {
                return
        }
        
        let annotation = annotationForLocation(location)
        mapView.addAnnotation(annotation)
    }
    
    // detects when a pin has been clicked
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
          print("pin clicked")
    }
}

extension MapViewController: MKMapViewDelegate {
    
    // creates a new AnnotationView for each added CustomPin annotation. this
    // function was taken from the MapKit tutorial at
    // https://www.raywenderlich.com/548-mapkit-tutorial-getting-started#toc-anchor-007
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // ensure the current annotation is the CustomPin type
        guard let annotation = annotation as? CustomPin else { return nil }
        
        let tempID = "CPAnnotation"
        var view: MKAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: tempID) as? MKMarkerAnnotationView {
                
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
         
            // create view for this restaurant annotation and give it a callout popup
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: tempID)
            view.canShowCallout = true
            
            /* will eventually use this section to add images of restaurants
             
            let tempUrl = URL(string: annotation.image_url!)!
            let tempData = try! Data(contentsOf: tempUrl)
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(data: tempData)
            */
            
            // create detail view and add to annotation
            let detailView = UIStackView()
            view.detailCalloutAccessoryView = detailView
            
            // create views for each of the CustomPin properties, then assign to stack view
            let addressView = UILabel()
            let phoneAndPriceView = UIStackView()
            phoneAndPriceView.axis = .horizontal
            phoneAndPriceView.distribution = .equalSpacing
            let phoneView = UILabel()
            let priceView = UILabel()
            phoneAndPriceView.addArrangedSubview(phoneView)
            phoneAndPriceView.addArrangedSubview(priceView)
            let reView = UILabel()
            detailView.addArrangedSubview(addressView)
            detailView.addArrangedSubview(phoneAndPriceView)
            detailView.addArrangedSubview(reView)
            detailView.axis = .vertical
            detailView.distribution = .equalCentering
            
            // modify view for address
            addressView.textColor = .darkGray
            addressView.text = annotation.subtitle
            // modify view for phone number
            phoneView.textColor = .darkGray
            phoneView.text = annotation.display_phone
            // modify view for price
            priceView.textColor = .darkGray
            priceView.text = annotation.price
            // modify view for review score
            reView.textColor = .darkGray
            reView.text = "Rated \(String(describing: annotation.rating!)) stars from \(String(describing: annotation.review_count!)) reviews"
        }
        
        return view
    }
   
    
 
}

/*
func openGoogleMaps() {
    
    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
        UIApplication.shared.openURL(URL(string:
            "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic")!)
    } else {
        print("Can't use comgooglemaps://")
    }
 
}
*/


// started function to link to google maps



