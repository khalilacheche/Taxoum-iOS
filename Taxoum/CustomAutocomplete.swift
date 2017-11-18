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

class CustomAutocomplete: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var Search: UITextField!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var searchBar: UISearchBar!
    var fetcher : GMSAutocompleteFetcher = GMSAutocompleteFetcher(bounds:nil,filter:nil)
    var delegate:CustomAutocompleteDelegate? = nil
    public var results = [Place]()
    let myPostion:Place = Place(Name: "My position", Locality: nil , ID: nil)
    let SelectOnMap:Place = Place(Name: "Select On Map", Locality: nil , ID: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        Search.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 37.365733,
                                                    longitude: 11.852234)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 30.046239,
                                                    longitude: 7.213625)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner,
                                         coordinate: swBoundsCorner)
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: nil)
        fetcher.delegate = self
       // Search.delegate=self
        results.append(myPostion)
        results.append(SelectOnMap)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        fetcher.sourceTextHasChanged(textField.text)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        
    }
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return results.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.Title.text=results[indexPath.row].Name
        cell.Subtitle.text=results[indexPath.row].Locality
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
                    print(location)
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
            //TO DO : Add an image next to the prediction
            //print(prediction.types[0])
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
