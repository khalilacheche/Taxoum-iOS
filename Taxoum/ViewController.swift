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
    var panelOriginalCenter: CGPoint!
    var panelDownOffset: CGFloat!
    var panelUp: CGPoint!
    var panelDown: CGPoint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panelDownOffset = 72
        panelUp = subView.center
        panelDown = CGPoint(x: subView.center.x ,y: subView.center.y + panelDownOffset)
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
            self.googleMaps.mapStyle = try GMSMapStyle(jsonString: "[{\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#7c93a3\"},{\"lightness\":\"-10\"}]},{\"featureType\":\"administrative.country\",\"elementType\":\"geometry\",\"stylers\":[{\"visibility\":\"on\"}]},{\"featureType\":\"administrative.country\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#a0a4a5\"}]},{\"featureType\":\"administrative.province\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#62838e\"}]},{\"featureType\":\"landscape\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#dde3e3\"}]},{\"featureType\":\"landscape.man_made\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#3f4a51\"},{\"weight\":\"0.30\"}]},{\"featureType\":\"poi\",\"stylers\":[{\"visibility\":\"simplified\"}]},{\"featureType\":\"poi.attraction\",\"stylers\":[{\"visibility\":\"on\"}]},{\"featureType\":\"poi.business\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.government\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.park\",\"stylers\":[{\"visibility\":\"on\"}]},{\"featureType\":\"poi.place_of_worship\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.school\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.sports_complex\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"road\",\"stylers\":[{\"saturation\":\"-100\"},{\"visibility\":\"on\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"visibility\":\"on\"}]},{\"featureType\":\"road.arterial\",\"elementType\":\"labels.icon\",\"stylers\":[{\"saturation\":\"-7\"},{\"invert_lightness\":true},{\"lightness\":\"3\"},{\"gamma\":\"1.80\"},{\"weight\":\"0.01\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#bbcacf\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#bbcacf\"},{\"lightness\":\"0\"},{\"weight\":\"0.50\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"labels\",\"stylers\":[{\"visibility\":\"on\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"labels.text\",\"stylers\":[{\"visibility\":\"on\"}]},{\"featureType\":\"road.highway.controlled_access\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#ffffff\"}]},{\"featureType\":\"road.highway.controlled_access\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#a9b4b8\"}]},{\"featureType\":\"transit\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"water\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#a3c7df\"}]}]")
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.showPartPanel()
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
        marker.icon = GMSMarker.markerImage(with: .blue)
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
        SelectStartLocation(place: location!, PlaceName: "My Position")
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
            self.showPartPanel()
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
    }
    func SelectEndLocation(place: CLLocation, PlaceName: String){
        locationEnd = place
        createMarker(titleMarker: PlaceName, /*iconMarker: #imageLiteral(resourceName: "mapspin"), */latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
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
        self.TaxiFare.text = "Taxi Fare:  " + String(finalTaxiFare) + " TND"
    }
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        

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
            self.showFullPanel()
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.cyan
                polyline.map = self.googleMaps
            }
            
        }
    }
    func showFullPanel(){
        UIView.animate(withDuration: 0.3) {
            self.subView.center = self.panelUp
        }

    }
    func showPartPanel(){
        UIView.animate(withDuration: 0.3) {
            self.subView.center = self.panelDown
        }
        
    }
    @IBAction func didSwipe(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: view)
        let translation = sender.translation(in: view)
        if sender.state == .began {
            panelOriginalCenter = subView.center
            
        } else if sender.state == .changed {
            subView.center = CGPoint(x: panelOriginalCenter.x, y: panelOriginalCenter.y + translation.y)
            if subView.center.y < panelUp.y {
                subView.center.y = panelUp.y
            }
            if subView.center.y > panelDown.y {
                subView.center.y = panelDown.y
            }
            
        } else if sender.state == .ended {
            if velocity.y > 0 {
                self.showPartPanel()
            } else {
                self.showFullPanel()
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
        createMarker(titleMarker: stm, /*iconMarker: #imageLiteral(resourceName: "mapspin") ,*/ latitude: (locationStart.coordinate.latitude), longitude: (locationStart.coordinate.longitude))
        createMarker(titleMarker: dtm,/* iconMarker: #imageLiteral(resourceName: "mapspin"),*/ latitude: locationEnd.coordinate.latitude, longitude: locationEnd.coordinate.longitude)
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

