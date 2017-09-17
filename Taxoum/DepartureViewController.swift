//
//  DepartureViewController.swift
//  Taxoum
//
//  Created by Amir Braham on 9/14/17.
//  Copyright © 2017 JKTronix. All rights reserved.
//

import UIKit
import Lottie
import GoogleMaps
import SwiftyJSON
import GooglePlaces
import GooglePlacesAPI
import Alamofire

class DepartureViewController: UIViewController , GMSMapViewDelegate ,  CLLocationManagerDelegate {

    var isSelectingOnMap:Bool = false
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    let pricebykm = 750
    let pricebyseconds = 30/9

    var stm:String="Start location"
    var dtm:String="End location"
    var mylocation :CLLocationCoordinate2D!
    @IBOutlet weak var startLocation: UITextField!
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        startLocation.text = "locations = \(mylocation.latitude) \(mylocation.longitude)"
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAutocomplete" {
            let AutocompleteController : CustomAutocomplete = segue.destination as! CustomAutocomplete
            AutocompleteController.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let locationAnimationView = LOTAnimationView(name: "location")
        self.view.addSubview(locationAnimationView)
        locationAnimationView.contentMode = .scaleAspectFill
        locationAnimationView.frame =  CGRect(x: 87 , y: 364, width: 200,height: 180)
        locationAnimationView.loopAnimation = true
        locationAnimationView.play()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        mylocation = locValue;
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func SelectStartLocation(place: CLLocation, PlaceName: String){
        locationStart = place
        stm = PlaceName
        startLocation.text=PlaceName
    }
    
    
}

extension DepartureViewController: CustomAutocompleteDelegate {
    func userDidSelectPlaceOnMap() {
        isSelectingOnMap=true
        if locationSelected == .startLocation {
            startLocation.text = "Select Your Start Location on the Map"
        }
    }
    func userDidSelectMyPosition() {
        startLocation.text = "locations = \(mylocation.latitude) \(mylocation.longitude)";
    }
    func userDidSelectPlace(Cooridnate: CLLocationCoordinate2D, Name: String) {
        let location = CLLocation(latitude: Cooridnate.latitude, longitude: Cooridnate.longitude)
        if locationSelected == .startLocation {
            SelectStartLocation(place: location, PlaceName: Name)
        }
    }
    func failAutocomplete() {
        print("Error")
    }
}
