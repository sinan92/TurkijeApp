//
//  HomeController.swift
//  Turkije App
//
//  Created by Sinan Samet on 31/10/2018.
//  Copyright © 2018 Sinan Samet. All rights reserved.
//

import UIKit
import CoreLocation

class HomeController: UIViewController {
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        enableLocationServices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
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
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
        
        let location = locationManager.location
        
        fetchCityAndCountry(from: location!) { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            self.locationLabel.text = city + ", " + country
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        locationLabel.text = String(lastLocation.coordinate.latitude)
        // Do something with the location.
        print(lastLocation)
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
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
