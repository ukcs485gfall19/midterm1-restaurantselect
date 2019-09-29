//
//  AppDelegate.swift
//  Midterm1
//
//  Created by Jonathan Moore on 9/17/19.
//  Copyright © 2019 Jonathan Moore. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let geoCoder = CLGeocoder()
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
        // Asking the user for notification permission, still not showing up
        locationManager.requestAlwaysAuthorization()
        // Asking the user for location use permission
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
        
        // Receive location updates when location changes for 35+ meters
        locationManager.distanceFilter = 35
        
        // Allow background location tracking
        locationManager.allowsBackgroundLocationUpdates = true
        
        // Start listening
        locationManager.startUpdatingLocation()
        
        return true
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // create CLLocation from the coordinates of CLVisit
        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        
        // Get location description
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                let description = "\(place)"
                self.newVisitReceived(visit, description: description)
            }
        }

    }
    
    func newVisitReceived(_ visit: CLVisit, description: String) {
        let location = Location(visit: visit, descriptionString: description)
        
        // Save location to disk
        
        
        let content = UNMutableNotificationContent()
        content.title = "Hey there 😃! You have a new Journal entry 📌"
        content.body = location.description
        content.sound = .default
        
      
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
        
        
        center.add(request, withCompletionHandler: nil)

        
    }
    
    // handles fake visits
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Discards all locations except the first
        guard let location = locations.first else {
            return
        }
        
        // Grabs location description
        AppDelegate.geoCoder.reverseGeocodeLocation(location) {
            placemarks, _ in
            if let place = placemarks?.first {
                
                // Marks visit as fake
                let description = "Fake visit: \(place)"
                
                // Creates a FakeVisit instance and passes it to newVisitReceived
                let fakeVisit = FakeVisit(
                    coordinates: location.coordinate,
                    arrivalDate: Date(),
                    departureDate: Date())
                self.newVisitReceived(fakeVisit, description: description)
            }
        }
    }
    
}

// subclass for fake CLVisits
final class FakeVisit: CLVisit {
    private let myCoordinates: CLLocationCoordinate2D
    private let myArrivalDate: Date
    private let myDepartureDate: Date
    
    override var coordinate: CLLocationCoordinate2D {
        return myCoordinates
    }
    
    override var arrivalDate: Date {
        return myArrivalDate
    }
    
    override var departureDate: Date {
        return myDepartureDate
    }
    
    init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
        myCoordinates = coordinates
        myArrivalDate = arrivalDate
        myDepartureDate = departureDate
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

