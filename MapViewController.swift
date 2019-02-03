//
//  ViewController.swift
//  Uber Food Truck
//
//  Created by Jeremy Chen on 2019/1/29.
//  Copyright © 2019 Jeremy Chen. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class storeClass: NSObject {
    var title: String
    var storeDescription: String

    var latitude: Double
    var longitude: Double
    init(title: String, storeDescription: String, latitude: Double, longitude: Double) {
        self.title = title
        self.storeDescription = storeDescription
        self.latitude = latitude
        self.longitude = longitude
    }
}

class MapViewController: UIViewController{
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var SearchTextField: UITextField!
    @IBOutlet weak var SearchButton: UIButton!

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var zoomLevel: Float = 14.0
    var storesFromServer = [storeClass]()
    var allMarkers: Array<GMSMarker> = Array()

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    let spinner = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add spinner effect for page loading, an UI friendly design
        activityIndicator.color = UIColor.black
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        self.view.addSubview(activityIndicator)

        // Make sure keyboard would dismiss when clicking ouside the editing area
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)

        // default view, would center at Uber HQ
        let camera = GMSCameraPosition.camera(withLatitude: 37.7811489,
                                              longitude: -122.4579986,
                                              zoom: zoomLevel)
        self.mapView.camera = camera

        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = false
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.isHidden = false

        getStoresFromServer()
    }

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        SearchTextField.resignFirstResponder()
        //        view.endEditing(true)
    }

    @IBAction func SearchButtonAction(_ sender: AnyObject) {
        self.hideKeyboardWhenTappedAround()

        if ((SearchTextField!.text != nil) && SearchTextField.text!.count > 1) {
            var searchText =  SearchTextField.text
            print("searchText: ",searchText!)
            var words = searchText!.split(separator: " ")
            let lastWord = words.last
            print("lastWord: ",lastWord!)
            if (lastWord == "nearby") {
                words.removeLast()
                searchText = words.joined(separator: " ")
                print(searchText!)
                getNearbyStoresByName(searchText: searchText!)
            } else {
                searchText = words.joined(separator: " ")
                print(searchText!)
                getStoresByName(searchText: searchText!)
            }
        } else {
            // So far, we only consider empty string as invalid search
            let alertController =
                UIAlertController(
                    title: "Invalid",
                    message:  "Please enter a valid store or dish name",
                    preferredStyle: UIAlertController.Style.alert)

            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }

            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)

            // Go back to show default initial markers for invalid search
            getStoresFromServer()
        }
    }

    // Call API server to get data from backend, and store in local data structure: storesFromServer
    func getStoresFromServer(){
        // XXX: Here goes headers and authentication data

        // Run spinner effect to show that a task is in progress
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        self.activityIndicator.startAnimating()

        let URL = "https://uber-foodtruck.herokuapp.com/api/shops"

        Alamofire.request(URL, method: .get)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // Remove existing dataFromServer so we only show markers for up-to-date results
                    self.storesFromServer.removeAll()

                    if let value = response.result.value {
                        let json = JSON(value)
                        print("StoresFromServer JSON: \(json)")

                        for result in json.arrayValue {
                            let status = result["Status"].stringValue
                            print("JSONdata status: \(status)")

                            if(status=="APPROVED"){
                                let title = result["Applicant"].stringValue
                                print("JSONdata title: \(title)")
                                let storeDescription = result["dayshours"].stringValue + "\n" + result["FoodItems"].stringValue
                                print("JSONdata Description: \(storeDescription)")

                                let lat = result["Latitude"].doubleValue
                                print("JSONdata lat: \(lat)")

                                let lon = result["Longitude"].doubleValue
                                print("JSONdata lon: \(lon)")

                                let store = storeClass(title: title, storeDescription: storeDescription, latitude: lat, longitude: lon)

                                self.storesFromServer.append(store)
                            }
                        }
                        self.activityIndicator.stopAnimating()
                        self.spinner.stopAnimating()
                        self.showStoresMarkerOnMap()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }

    func getStoresByName(searchText: String) {
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        let searchUrl = "https://uber-foodtruck.herokuapp.com/api/shops?filter[where][$text][search]="+escapedSearchText!
        print("searchUrl: ",searchUrl)

        // Run spinner effect to show that a task is in progress
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        self.activityIndicator.startAnimating()

        Alamofire.request(searchUrl, method: .get)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // Remove existing dataFromServer so we only show markers for up-to-date results
                    self.storesFromServer.removeAll()

                    if let value = response.result.value {
                        let json = JSON(value)
                        print("StoresFromServer JSON: \(json)")

                        for result in json.arrayValue {
                            let status = result["Status"].stringValue
                            print("JSONdata status: \(status)")

                            if(status=="APPROVED"){
                                let title = result["Applicant"].stringValue
                                print("JSONdata title: \(title)")
                                let storeDescription = result["dayshours"].stringValue + "\n" + result["FoodItems"].stringValue
                                print("JSONdata Description: \(storeDescription)")

                                let lat = result["Latitude"].doubleValue
                                print("JSONdata lat: \(lat)")

                                let lon = result["Longitude"].doubleValue
                                print("JSONdata lon: \(lon)")

                                let store = storeClass(title: title, storeDescription: storeDescription, latitude: lat, longitude: lon)

                                self.storesFromServer.append(store)
                            }
                        }
                        self.activityIndicator.stopAnimating()
                        self.spinner.stopAnimating()
                        self.showStoresMarkerOnMap()

                        if(self.storesFromServer.count != 0){
                            // if we have search results to show, center app view into one of the result
                            let camera =
                                GMSCameraPosition.camera(
                                    withLatitude: self.storesFromServer[0].latitude,
                                    longitude: self.storesFromServer[0].longitude,
                                    zoom: self.zoomLevel)
                            self.mapView.camera = camera
                        }
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }

    func getNearbyStoresByName(searchText: String) {
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        let searchUrl = "https://uber-foodtruck.herokuapp.com/api/shops/nearby/?name="+escapedSearchText!
        print("searchUrl: ",searchUrl)

        // Run spinner effect to show that a task is in progress
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        self.activityIndicator.startAnimating()

        Alamofire.request(searchUrl, method: .get)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // Remove existing dataFromServer so we only show markers for up-to-date results
                    self.storesFromServer.removeAll()

                    if let value = response.result.value {
                        let json = JSON(value)
                        print("StoresFromServer JSON: \(json)")

                        for result in json.arrayValue {
                            let status = result["Status"].stringValue
                            print("JSONdata status: \(status)")

                            if(status=="APPROVED"){
                                let title = result["Applicant"].stringValue
                                print("JSONdata title: \(title)")
                                let storeDescription = result["dayshours"].stringValue + "\n" + result["FoodItems"].stringValue
                                print("JSONdata Description: \(storeDescription)")

                                let lat = result["Latitude"].doubleValue
                                print("JSONdata lat: \(lat)")

                                let lon = result["Longitude"].doubleValue
                                print("JSONdata lon: \(lon)")

                                let store = storeClass(title: title, storeDescription: storeDescription, latitude: lat, longitude: lon)

                                self.storesFromServer.append(store)
                            }
                        }
                        self.activityIndicator.stopAnimating()
                        self.spinner.stopAnimating()
                        self.showStoresMarkerOnMap()

                        if(self.storesFromServer.count != 0){
                            // if we have search results to show, center app view into one of the result
                            let camera =
                                GMSCameraPosition.camera(
                                    withLatitude: self.storesFromServer[0].latitude,
                                    longitude: self.storesFromServer[0].longitude,
                                    zoom: self.zoomLevel)
                            self.mapView.camera = camera
                        }
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }

    // Draw markers on the MapView
    func showStoresMarkerOnMap() {
        // clear all markers on the map
        self.mapView.clear()

        for store in storesFromServer {
            let title = store.title
            let storeDescription = store.storeDescription

            let lat = store.latitude
            let lon = store.longitude
            let position = CLLocationCoordinate2DMake(lat, lon)

            let marker = GMSMarker(position: position)
            marker.title = title
            marker.snippet = storeDescription
            marker.isFlat = true
            marker.map = self.mapView
        }
    }
}

// Hide keyboard when tapped somewhere around ouside the text editing area
// ref: https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
