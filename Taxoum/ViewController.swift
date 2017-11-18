//
//  ViewController.swift
//  Taxoum
//
//  Created by Khalil on 06/07/2017.
//  Copyright © 2017 JKTronix. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import GooglePlaces
import GooglePlacesAPI
import Alamofire

enum Location {
    case startLocation
    case destinationLocation
}

class ViewController: UIViewController , GMSMapViewDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet weak var TaxiFare: UILabel!
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!

    
    var isSelectingOnMap:Bool = false
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart :CLLocationCoordinate2D = CLLocationCoordinate2D()
    var locationEnd :CLLocationCoordinate2D = CLLocationCoordinate2D()
    let pricebykm = 750
    let pricebyseconds = 30/9
    var stm:String="Start location"
    var dtm:String="End location"
    var mylocation :CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.startMonitoringSignificantLocationChanges()
        //Your map initiation code
        let camera = GMSCameraPosition.camera(withLatitude: -7.9293122, longitude: 112.5879156, zoom: 15.0)
        
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAutocomplete" {
            let AutocompleteController : CustomAutocomplete = segue.destination as! CustomAutocomplete
            AutocompleteController.delegate = self
        }
    }
    
    // MARK: function for create a marker pin on map
    func createMarker(titleMarker: String, /*iconMarker: UIImage,*/ latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        //marker.icon = iconMarker
        marker.map = googleMaps
    }
    
    //MARK: - Location Manager delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        mylocation = locValue
        print(mylocation)
        SelectStartLocation(place: mylocation,PlaceName: "My Position")
        let camera = GMSCameraPosition.camera(withLatitude: (mylocation.latitude), longitude: (mylocation.longitude), zoom: 17.0)
        
        self.googleMaps?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMaps.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMaps.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMaps.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if isSelectingOnMap{
            let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            if locationSelected == .startLocation {
                SelectStartLocation(place: location, PlaceName: String(coordinate.latitude) + ", " + String(coordinate.longitude))
            }else if locationSelected == .destinationLocation {
                SelectEndLocation(place: location, PlaceName: String(coordinate.latitude) + ", " + String(coordinate.longitude))
            }
        isSelectingOnMap=false
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps.isMyLocationEnabled = true
        googleMaps.selectedMarker = nil
        return false
    }
    
    
    
    //MARK: - this is function for create direction path, from start location to desination location
    func SelectStartLocation(place: CLLocationCoordinate2D, PlaceName: String){
        locationStart = place
        createMarker(titleMarker: PlaceName,/* iconMarker: #imageLiteral(resourceName: "mapspin"),*/ latitude: place.latitude, longitude: place.longitude)
        stm = PlaceName
        startLocation.text=PlaceName
    }
    func SelectEndLocation(place: CLLocationCoordinate2D, PlaceName: String){
        locationEnd = place
        createMarker(titleMarker: PlaceName, /*iconMarker: #imageLiteral(resourceName: "mapspin"), */latitude: place.latitude, longitude: place.longitude)
        dtm = PlaceName
        destinationLocation.text = PlaceName
    }
    func CalculateTaxiFare(distanceinKM: Int , timeinSeconds: Int){
        var TaxifarebyDist:Int=0
        var TaxifarebyTime:Int=0
        //Getting local hour
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        print(hour)

        if hour>=21 || hour<=5 {
            TaxifarebyDist = (450 + distanceinKM/1000 * self.pricebykm) + (450 + distanceinKM/1000 * self.pricebykm ) / 2
            TaxifarebyTime = (450 + timeinSeconds * self.pricebyseconds) + (450 + timeinSeconds * self.pricebyseconds) / 2
        }else if hour<21 || hour>5 {
                TaxifarebyDist = 450 + distanceinKM/1000 * self.pricebykm
                TaxifarebyTime = 450 + timeinSeconds * self.pricebyseconds
        }

        print("Taxi fare by distance: ",TaxifarebyDist)
        print("Taxi fare by time: ",TaxifarebyTime)
        let finalTaxiFare = (TaxifarebyTime  +  TaxifarebyDist ) / 2
        print ("Final Taxi Fare  ",finalTaxiFare)
        self.TaxiFare.text = "Taxi Fare:  " + String(finalTaxiFare)
    }
    func drawPath(startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D)
    {
        let origin = "\(startLocation.latitude),\(startLocation.longitude)"
        let destination = "\(endLocation.latitude),\(endLocation.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        //Requesting the routes
        Alamofire.request(url).responseJSON { response in
            
            //print(response.request as Any)  // original URL request
            //print(response.response as Any) // HTTP URL response
            //print(response.data as Any)     // server data
            //print(response.result as Any)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            let distanceinKM = json["routes"][0]["legs"][0]["distance"]["value"].intValue
            let timeInSeconds = json["routes"][0]["legs"][0]["duration"]["value"].intValue
            print(distanceinKM)
            print(timeInSeconds)
            self.CalculateTaxiFare(distanceinKM: distanceinKM, timeinSeconds: timeInSeconds)
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.googleMaps
            }
            
        }
    }
    
    // MARK: when start location tap, this will open the search location
    @IBAction func openStartLocation(_ sender: UIButton) {
        locationSelected = .startLocation
        self.locationManager.stopUpdatingLocation()
        performSegue(withIdentifier: "toAutocomplete", sender: nil)
    }
    
    // MARK: when destination location tap, this will open the search location
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        locationSelected = .destinationLocation
        
        self.locationManager.stopUpdatingLocation()
        performSegue(withIdentifier: "toAutocomplete", sender: nil)
    }
    
    @IBAction func SwitchPlaces(_ sender: Any) {
        let newStart = locationEnd
        locationEnd = locationStart
        locationStart = newStart
        let newstm = dtm
        dtm = stm
        stm = newstm
        SelectStartLocation(place: locationStart, PlaceName: stm)
        SelectEndLocation(place: locationEnd, PlaceName: dtm)
        
    }
    @IBAction func selectMyPositionAtStart(_ sender: Any) {
        SelectStartLocation(place: mylocation, PlaceName: "My Position")
    }
    @IBAction func selectMyPositionAtDestination(_ sender: Any) {
        SelectEndLocation(place: mylocation, PlaceName: "My Position")
    }
    
    // MARK: SHOW DIRECTION WITH BUTTON
    @IBAction func showDirection(_ sender: UIButton) {
        // when button direction tapped, must call drawpath func
        googleMaps.clear()
        self.drawPath(startLocation: locationStart, endLocation: locationEnd)
        createMarker(titleMarker: stm, /*iconMarker: #imageLiteral(resourceName: "mapspin") ,*/ latitude: (locationStart.latitude), longitude: (locationStart.longitude))
        createMarker(titleMarker: dtm,/* iconMarker: #imageLiteral(resourceName: "mapspin"),*/ latitude: locationEnd.latitude, longitude: locationEnd.longitude)
    }
    
}
extension ViewController: CustomAutocompleteDelegate {
    func userDidSelectPlaceOnMap() {
        isSelectingOnMap=true
        if locationSelected == .startLocation {
          startLocation.text = "Select Your Start Location on the Map"
        }else if locationSelected == .destinationLocation {
          destinationLocation.text = "Select Your End Location on the Map"
        }
    }
    func userDidSelectMyPosition() {
        self.googleMaps.camera = GMSCameraPosition.camera(withLatitude: mylocation.latitude, longitude: mylocation.longitude, zoom: 16.0)
        if locationSelected == .startLocation {
            SelectStartLocation(place: mylocation, PlaceName: "My Position")
        }else if locationSelected == .destinationLocation {
            SelectEndLocation(place: mylocation, PlaceName: "My Position")
        }
    }
    func userDidSelectPlace(Cooridnate: CLLocationCoordinate2D, Name: String) {
        let location = CLLocationCoordinate2D(latitude: Cooridnate.latitude, longitude: Cooridnate.longitude)
        self.googleMaps.camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 16.0)
        if locationSelected == .startLocation {
            SelectStartLocation(place: location, PlaceName: Name)
        }else if locationSelected == .destinationLocation {
            SelectEndLocation(place: location, PlaceName: Name)
        }
    }
    func failAutocomplete() {
        print("Error")
    }
}

