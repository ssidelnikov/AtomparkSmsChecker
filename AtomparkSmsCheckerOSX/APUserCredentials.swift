//
//  UserCredentials.swift
//  AtomparkSmsChecker
//
//  Created by Stanislav Sidelnikov on 27/11/15.
//
//

import Foundation

/// This is an ugly hack because cookies don't persist between app restarts
// TODO Find a way to persist cookies or store them and read back instead of the password
class APUserCredentials {
    class func saveUsername(username: String, withPassword password: String) {
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
        NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
    }
    
    class func getSavedCredentials() -> (username: String?, password: String?) {
        let username = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String
        let password = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
        
        return (username, password)
    }
}
