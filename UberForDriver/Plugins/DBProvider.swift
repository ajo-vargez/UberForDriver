//
//  DBProvider.swift
//  UberForDriver
//
//  Created by Ajo M Varghese on 16/09/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import Foundation
import Firebase

class DBProvider {
    
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference();
    }
    
    var driverRef: DatabaseReference {
        return dbRef.child(Constants.DRIVERS);
    }
    
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.UBER_REQUEST);
    }
    
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.UBER_ACCEPTED);
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email,
                                             Constants.PASSWORD: password,
                                             Constants.isRider: false];
        driverRef.child(withID).child(Constants.DATA).setValue(data);
    }
    
} // Class
