//
//  AutocompletTest.swift
//  Taxoum
//
//  Created by Khalil on 02/08/2017.
//  Copyright © 2017 JKTronix. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacesAPI
protocol CustomAutocompleteDelegate {
    func userDidSelectPlace(Cooridnate: CLLocationCoordinate2D,Name:String)
    func userDidSelectMyPosition()
    func userDidSelectPlaceOnMap()
    func failAutocomplete()
}

class CustomAutocomplete: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var fetcher : GMSAutocompleteFetcher = GMSAutocompleteFetcher(bounds:nil,filter:nil)
    var delegate:CustomAutocompleteDelegate? = nil
    public var results = [Place]()
    let myPostion:Place = Place(Name: "My position", Locality: nil , ID: nil)
    let SelectOnMap:Place = Place(Name: "Select On Map", Locality: nil , ID: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 37.365733,
                                                    longitude: 11.852234)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 30.046239,
                                                    longitude: 7.213625)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner,
                                         coordinate: swBoundsCorner)
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: nil)
        fetcher.delegate = self
        searchBar.delegate=self
        results.append(myPostion)
        results.append(SelectOnMap)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetcher.sourceTextHasChanged(searchText)
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        
    }
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return results.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text=results[indexPath.row].Name
        cell.detailTextLabel?.text=results[indexPath.row].Locality
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if (delegate != nil){
            if indexPath.row == 0 {
                delegate?.userDidSelectMyPosition()
                self.dismiss(animated: true, completion: nil)
            }else if indexPath.row == 1 {
                delegate?.userDidSelectPlaceOnMap()
                self.dismiss(animated: true, completion: nil)
            }else{
                let placesClient:GMSPlacesClient=GMSPlacesClient()
                var location:CLLocationCoordinate2D=CLLocationCoordinate2D()
                var locationName:String=String()
                placesClient.lookUpPlaceID(results[indexPath.row].ID!, callback: { (place, error) in
                    if let error = error {
                        self.delegate?.failAutocomplete()
                        self.dismiss(animated: true, completion: nil)
                        print("lookup place id query error: \(error.localizedDescription)")
                        return
                    }
                location=(place?.coordinate)!
                locationName=(place?.name)!
                self.delegate?.userDidSelectPlace(Cooridnate: location, Name: locationName)
                self.dismiss(animated: true, completion: nil)
                })
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)

        
    }

}
class Place{
    var Name:String?
    var Locality:String?
    var ID:String?
    init (Name: String?, Locality: String?, ID:String?) {
        self.Name = Name
        self.Locality = Locality
        self.ID = ID
    }
}
extension CustomAutocomplete: GMSAutocompleteFetcherDelegate {

    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        results.removeAll()
        results.append(myPostion)
        results.append(SelectOnMap)
        for prediction in predictions {
            let obj:Place=Place(Name:prediction.attributedPrimaryText.string,Locality:prediction.attributedSecondaryText?.string,ID:prediction.placeID)
            results.append(obj)
        }
     tableView.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        results.removeAll()
        let obj:Place=Place(Name: error.localizedDescription, Locality: nil, ID: nil)
         results.append(obj)
        tableView.reloadData()
    }
    
}
