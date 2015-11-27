//
//  APNetworker.swift
//  AtomparkSmsChecker
//
//  Created by Stanislav Sidelnikov on 25/11/15.
//
//

enum APNetworkerError : ErrorType {
    case InvalidServerName
    case IncorrectUrlParameters
}

public class APNetworker : NSObject {
    static let serverName = "https://myatompark.com"
    var path : String
    var session : NSURLSession
    
    init(session: NSURLSession, path: String) {
        self.path = path
        self.session = session
    }
    
    public func fetchParameters(parameters: [String: String]?, completion: ((AnyObject?, NSError?) -> Void)) throws {
        try performRequest("GET", withParameters: parameters, completion: {(data, response, error) in
            completion(data, error)
        })
    }
    
    public func performRequest(method: String, withParameters parameters: [String: String]?, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)) throws {
        guard let components = NSURLComponents(string: APNetworker.serverName) else {
            throw APNetworkerError.InvalidServerName
        }
        
        if !self.path.isEmpty {
            var path = self.path
            if !path.hasPrefix("/") {
                path = "/" + path
            }
            components.path = path
        }
        
        var httpBody : String?
        if parameters?.count > 0 {
            if method == "GET" {
                components.queryItems = parameters!.map({ NSURLQueryItem(name: $0, value: $1) })
            } else {
                httpBody = parameters!.map({ "\($0)=\($1)" }).joinWithSeparator("&")
            }
        }
        
        guard let url = components.URL else {
            throw APNetworkerError.IncorrectUrlParameters
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        if (httpBody != nil) {
            request.HTTPBody = httpBody!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        }
        
        let task = self.session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            if (error != nil) {
                print(error!.description)
            }
            
            completion(data, response, error)
        })
        
        task.resume()
    }
}