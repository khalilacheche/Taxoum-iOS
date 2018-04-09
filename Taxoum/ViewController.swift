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

class ViewController: UIViewController , GMSMapViewDelegate ,  CLLocationManagerDelegate {
    
    @IBOutlet weak var TaxiFare: UILabel!
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var RatingSlider: UISlider!
    var isSelectingOnMap:Bool = false
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    let pricebykm = 750
    let pricebyseconds = 30/9
    var stm:String="Start location"
    var dtm:String="End location"
    var mylocation :CLLocation!
    var Markers : [GMSMarker] = []
    
    
    override func viewDidLoad() {
        print("start Location ",  startLocation)
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        //Your map initiation code
        let camera = GMSCameraPosition.camera(withLatitude: -7.9293122, longitude: 112.5879156, zoom: 15.0)
        
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        do {
            // Set the map style by passing a valid JSON string.
            if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
                self.googleMaps.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }
            
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
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
        Markers.append(marker)
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = GMSMarker.markerImage(with: .red)
        //marker.icon = iconMarker
        marker.map = googleMaps
    }
    
    //MARK: - Location Manager delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        mylocation=location!
        //SelectStartLocation(place: location!, PlaceName: "My Position")
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
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
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng="+String(coordinate.latitude)+","+String(coordinate.longitude)+"&key=AIzaSyAbeuFxWsVTrADl6YJQQGuHmlarwP-gaf8"
            Alamofire.request(url).responseJSON { response in
                
                //print(response.request as Any)  // original URL request
                //print(response.response as Any) // HTTP URL response
                //print(response.data as Any)     // server data
                //print(response.result as Any)   // result of response serialization
                
                //let json = JSON(data: response.data!)
                //let address = json["results"][0]["formatted_address"]
                //print(address)
                
            }
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
    func SelectStartLocation(place: CLLocation, PlaceName: String){
        locationStart = place
        createMarker(titleMarker: PlaceName,/* iconMarker: #imageLiteral(resourceName: "mapspin"),*/ latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        stm = PlaceName
        startLocation.text=PlaceName
        showDirection()
    }
    func SelectEndLocation(place: CLLocation, PlaceName: String){
        locationEnd = place
        createMarker(titleMarker: PlaceName, /*iconMarker: #imageLiteral(resourceName: "mapspin"), */latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        dtm = PlaceName
        destinationLocation.text = PlaceName
        showDirection()
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
        
        if(TaxifarebyDist == 0 ) {
            self.showDirection()
        }
        print("Taxi fare by distance: ",TaxifarebyDist)
        print("Taxi fare by time: ",TaxifarebyTime)
        let finalTaxiFare = (TaxifarebyTime  +  TaxifarebyDist ) / 2
        print ("Final Taxi Fare  ",finalTaxiFare)
        self.TaxiFare.text = "Taxi Fare:  " + String(finalTaxiFare) + " TND"
    }
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        print("start location ",startLocation.coordinate)
        print("end location ",endLocation.coordinate)

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
            var bounds = GMSCoordinateBounds()
            for marker in self.Markers
            {
                bounds = bounds.includingCoordinate(marker.position)
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
            self.googleMaps.animate(with: update)
            self.googleMaps.animate(toLocation: CLLocationCoordinate2D(latitude: (startLocation.coordinate.latitude + endLocation.coordinate.latitude ) / 2 , longitude:  (startLocation.coordinate.longitude + endLocation.coordinate.longitude ) / 2  ))
           // self.googleMaps.animate(toZoom: Float(distanceinKM/1000) )

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
                polyline.strokeColor =  self.hexStringToUIColor(hex: "#54a0ff")
                polyline.map = self.googleMaps
            }
            
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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

    @IBAction func selectMyPositionAtStart(_ sender: Any) {
        SelectStartLocation(place: mylocation, PlaceName: "My Position")
    }
    @IBAction func selectMyPositionAtDestination(_ sender: Any) {
        SelectEndLocation(place: mylocation, PlaceName: "My Position")
    }
    
    // MARK: SHOW DIRECTION WITH BUTTON
    func showDirection() {
        if(locationStart.coordinate.latitude != 0 && locationEnd.coordinate.latitude != 0) {
            // when button direction tapped, must call drawpath func
            googleMaps.clear()
            self.drawPath(startLocation: locationStart, endLocation: locationEnd)
            createMarker(titleMarker: stm, /*iconMarker: #imageLiteral(resourceName: "mapspin") ,*/ latitude: (locationStart.coordinate.latitude), longitude: (locationStart.coordinate.longitude))
            createMarker(titleMarker: dtm,/* iconMarker: #imageLiteral(resourceName: "mapspin"),*/ latitude: locationEnd.coordinate.latitude, longitude: locationEnd.coordinate.longitude)
        }

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
        self.googleMaps.camera = GMSCameraPosition.camera(withLatitude: mylocation.coordinate.latitude, longitude: mylocation.coordinate.longitude, zoom: 16.0)
        if locationSelected == .startLocation {
            SelectStartLocation(place: mylocation, PlaceName: "My Position")
        }else if locationSelected == .destinationLocation {
            SelectEndLocation(place: mylocation, PlaceName: "My Position")
        }
    }
    func userDidSelectPlace(Cooridnate: CLLocationCoordinate2D, Name: String) {
        let location = CLLocation(latitude: Cooridnate.latitude, longitude: Cooridnate.longitude)
        self.googleMaps.camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 16.0)
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
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

