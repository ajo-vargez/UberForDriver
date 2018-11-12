//
//  AuthProvider.swift
//  UberForDriver
//
//  Created by Ajo M Varghese on 12/09/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import Foundation
import Firebase

typealias LoginHandler = (_ msg: String?) -> Void

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid email ID, Please enter a valid email address";
    static let WRONG_PASSWORD = "Wrong Password, Please enter the correct password";
    static let NETWORK_ERROR = "Problem connecting to Database, try again after sometime!";
    static let USER_NOT_FOUND = "Please Register, User does not exist";
    static let EMAIL_ALREADY_IN_USE = "Email already in use, Please use another email address";
}

class AuthProvider {
    
    private static let _instance = AuthProvider();
    static var Instance: AuthProvider {
        return _instance;
    }
    
    func  logIn(withEmail: String, password: String, loginHandler: LoginHandler?){
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler);
            } else {
                loginHandler?(nil);
            }
        }
    }
    
    func register(withEmail: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().createUser(withEmail: withEmail, password: password) { (userData, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler);
            } else {
                if userData?.user.uid != nil {
                    //Store user details in the Database
                    DBProvider.Instance.saveUser(withID: (userData?.user.uid)!, email: withEmail, password: password);
                    self.logIn(withEmail: withEmail, password: password, loginHandler: loginHandler);
                }
            }
        }
    }
    
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut();
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        if let errCode = AuthErrorCode(rawValue: err.code) {
            switch errCode {
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE);
                break;
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL);
                break;
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND);
                break;
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD);
                break;
            default:
                loginHandler?(LoginErrorCode.NETWORK_ERROR);
                break;
            }
        }
    }
} // Class
