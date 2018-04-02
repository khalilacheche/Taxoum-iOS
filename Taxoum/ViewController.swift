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
import Presentr
enum Location {
    case startLocation
    case destinationLocation
}

class ViewController: UIViewController , GMSMapViewDelegate ,  CLLocationManagerDelegate {
    
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var subView: UIView!
    
    var isSelectingOnMap:Bool = false
    let pricebykm = 750
    let pricebyseconds = 30/9
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Your map initiation code
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        do {
                // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
            if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
                self.googleMaps.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)

            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }

    
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

        isSelectingOnMap=false
        }
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
    }
    
    
    @IBAction func ShowRecentTrips(_ sender: UIButton) {
     let presenter = Presentr(presentationType: .alert)

        
        let controller = RecentTripsViewController()

        customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
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

  
}
