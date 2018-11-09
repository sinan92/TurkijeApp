//
//  HomeController.swift
//  Turkije App
//
//  Created by Sinan Samet on 31/10/2018.
//  Copyright © 2018 Sinan Samet. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class HomeController: UIViewController {
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    let locationManager = CLLocationManager()
    func enableLocationServices() {
        locationManager.delegate = self as? CLLocationManagerDelegate
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            locationManager.requestAlwaysAuthorization()
            locationLabel.text = "Locatie toegang geweigerd"
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            getCityOfLocation()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            getCityOfLocation()
            break
        }
    }
    
    func getCityOfLocation() {
        startReceivingSignificantLocationChanges()
    }
    
    func startReceivingSignificantLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The service is not available.
            return
        }
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        guard let location = locationManager.location else {
            print("No location found")
            return
        }
        updateLocation(location: location, boolean: true)
    }
    
    func updateLocation(location: CLLocation, boolean: Bool) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)-> Void in
            if error != nil {
                return
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                self.locationLabel.text = placemark.locality! + ", " + placemark.country!
                //if placemark.locality! !== previousCity) {
                    // Send push notification
                    let notification = UNMutableNotificationContent()
                    notification.body = "Your current location is: " + placemark.locality! + ", " + placemark.country!
                    
                    let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                    let request = UNNotificationRequest(identifier: "notification1", content: notification, trigger: notificationTrigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
        })
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        updateLocation(location: lastLocation, boolean: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
