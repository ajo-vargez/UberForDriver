//
//  MainVC.swift
//  UberForDriver
//
//  Created by Ajo M Varghese on 12/09/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberControllerDelegate {

    // MARK : - Declaration
    @IBOutlet weak var mapView: MKMapView!;
    @IBOutlet weak var driveButton: UIButton!;
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var riderLocation: CLLocationCoordinate2D?;
    
    private var timer = Timer();
    private var acceptedUber = false;
    private var driverCancelledUber = false;
    
    @IBAction func signOut(_ sender: AnyObject) {
        if AuthProvider.Instance.logOut() {
            if acceptedUber {
                driveButton.isHidden = true;
                UberHandler.Instance.uberCancelledByDriver();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
        } else {
            uberRequest(title: "Problem Logging Out", message: "Could not logOut at the moment, Please try after sometime", requestIsAlive: false);
        }
    }
    
    @IBAction func cancelRide(_ sender: AnyObject) {
        if acceptedUber {
            driverCancelledUber = true;
            driveButton.isHidden = true;
            UberHandler.Instance.uberCancelledByDriver();
            timer.invalidate();
        }
    }
    
    // MARK : - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad();
        
        initializeLocationManager();
        
        UberHandler.Instance.delegate = self;
        UberHandler.Instance.observeMessagesForDriver();
    }
    
    // MARK : - Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude);
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            mapView.setRegion(region, animated: true);
            
            mapView.removeAnnotations(mapView.annotations);
            
            if riderLocation != nil {
                if acceptedUber {
                    let riderAnnotation = MKPointAnnotation();
                    riderAnnotation.coordinate = riderLocation!;
                    riderAnnotation.title = "Rider's Location";
                    mapView.addAnnotation(riderAnnotation);
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Driver's Location";
            mapView.addAnnotation(annotation);
        }
    }
    
    func acceptUber(lat: Double, lon: Double) {
        if !acceptedUber {
            uberRequest(title: "Uber Request", message: "You have a pick-up at this location, latitude:\(lat) & longitude:\(lon)", requestIsAlive: true);
        }
    }
    
    func riderCancelledUber() {
        if !driverCancelledUber {
            UberHandler.Instance.uberCancelledByDriver();
            self.acceptedUber = false;
            self.driveButton.isHidden = true;
            uberRequest(title: "Uber Cancelled", message: "The rider has cancelled the uber", requestIsAlive: false);
        }
    }
    
    func driverCancelledUberRide() {
        acceptedUber = false;
        driveButton.isHidden = true;
        timer.invalidate();
    }
    
    func updateRidersLocation(lat: Double, lon: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon);
    }
    
    // MARK : - User/Custom Methods
    func initializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    @objc func updateLocation() {
        UberHandler.Instance.updateDriverLocation(lat: Double(userLocation!.latitude), lon: Double(userLocation!.longitude));
    }
    
    private func uberRequest(title: String, message: String, requestIsAlive: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        if requestIsAlive {
            let accept = UIAlertAction(title: "Accept", style: UIAlertAction.Style.default) { (alertAction) in
                self.acceptedUber = true;
                self.driveButton.isHidden = false;
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(60), target: self, selector: #selector(MainVC.updateLocation), userInfo: nil, repeats: true);
                UberHandler.Instance.uberAccepted(lat: Double(self.userLocation!.latitude), lon: Double(self.userLocation!.longitude));
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil);
            
            alert.addAction(accept);
            alert.addAction(cancel);
        } else {
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil);
            alert.addAction(ok);
        }
        present(alert, animated: true, completion: nil);
    }
    
} // Class
