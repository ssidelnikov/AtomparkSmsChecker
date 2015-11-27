//
//  APLogin.swift
//  AtomparkSmsChecker
//
//  Created by Stanislav Sidelnikov on 25/11/15.
//
//

import Foundation

public class APLogin : NSObject, NSURLSessionTaskDelegate {
    public var loggedIn : Bool {
        var hasSessId = false
        
        let url = NSURL(string: APNetworker.serverName)!
        let cookiesArray = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(url)!
        for cookie in cookiesArray {
            if cookie.name == "PHPSESSID" {
                hasSessId = true
            }
        }
        
        return hasSessId;
    }
    
    public func performLoginForUser(username: String, withPassword password: String, completion:((Bool, NSError?)->Void)?) throws {
        if self.loggedIn {
            self.performLogout()
        }
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.HTTPShouldSetCookies = true
        let urlSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let networker = APNetworker(session: urlSession, path: "/login")
        let params = ["login": username, "password": password]
        
        let completionHandler = {(data: NSData?, response: NSURLResponse?, error: NSError?) in
            var success = false
            if let responseHeaders = (response as? NSHTTPURLResponse)?.allHeaderFields as? [String: String] {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(responseHeaders, forURL: response!.URL!)
                success = cookies.map({$0.name}).indexOf("PHPSESSID") != nil
            }
            completion?(success, error)
        }
        
        try networker.performRequest("POST", withParameters: params, completion: completionHandler)
    }
    
    public func performLogout() {
    }
    
    // MARK - NSURLSessionTaskDelegate
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        completionHandler(nil)
    }
}