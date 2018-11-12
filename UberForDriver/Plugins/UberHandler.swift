//
//  UberHandler.swift
//  UberForDriver
//
//  Created by Ajo M Varghese on 17/09/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import Foundation
import Firebase

protocol UberControllerDelegate: class {
    func acceptUber(lat: Double, lon: Double);
    func riderCancelledUber();
    func driverCancelledUberRide();
    func updateRidersLocation(lat: Double, lon: Double);
}

class UberHandler {
    
    private static let _instance = UberHandler();
    
    static var Instance: UberHandler {
        return _instance;
    }
    
    var rider = "";
    var driver = "";
    var driver_id = "";
    
    weak var delegate: UberControllerDelegate?;
    
    func observeMessagesForDriver() {
        // Rider Requested an Uber
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] {
                    if let longitude = data[Constants.LONGITUTE] {
                        self.delegate?.acceptUber(lat: latitude as! Double, lon: longitude as! Double);
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.rider = name;
                }
            }
            // Rider Cancelled Uber
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved, with: { (snapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.rider {
                            self.rider = "";
                            self.delegate?.riderCancelledUber();
                        }
                    }
                }
            })
        }
        // Update Rider Location
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let lon = data[Constants.LONGITUTE] as? Double {
                        self.delegate?.updateRidersLocation(lat: lat, lon: lon);
                    }
                }
            }
        }
        // Driver Accepts Uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver_id = snapshot.key;
                    }
                }
            }
        }
        // Driver Cancelled Uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.delegate?.driverCancelledUberRide();
                    }
                }
            }
        }
    }
    
    func uberAccepted(lat: Double, lon: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: driver,
                                             Constants.LATITUDE: lat,
                                             Constants.LONGITUTE: lon];
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data);
    }
    
    func uberCancelledByDriver() {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue();
    }
    
    func updateDriverLocation(lat: Double, lon: Double) {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LATITUDE : lat, Constants.LATITUDE: lon]);
    }
    
} // Class
