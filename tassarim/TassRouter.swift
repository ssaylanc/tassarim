//
//  TassRouter.swift
//  tassarim
//
//  Created by saylanc on 15/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

/*import Foundation
import Alamofire

enum TassRouter: URLRequestConvertible {
    static let baseURLString = "https://api.dribbble.com/v1/"
    
    case get(Int)
    case create([String: AnyObject])
    case delete(Int)
    /*case
    case LoadAuthUSer()
    case isAuthenticated()
    case LoadUserFollowingShots()
    case LoadShots()
    */
    
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .get:
                return .GET
            case .create:
                return .POST
            case .delete:
                return .DELETE
            //case .LoadAuthUSer():
             //   return .GET
            }
        }
        let url:URL = {
            // build up and return the URL for each endpoint
            let relativePath:String?
            switch self {
            case .get(let postNumber):
                relativePath = "posts/\(postNumber)"
            case .create:
                relativePath = "posts"
            case .delete(let postNumber):
                relativePath = "posts/\(postNumber)"
            }
            
            var URL = Foundation.URL(string: TassRouter.baseURLString)!
            if let relativePath = relativePath {
                URL = URL.appendingPathComponent(relativePath)
            }
            return URL
        }()
        
        let params: ([String: AnyObject]?) = {
            switch self {
            case .delete:
                return (nil)
            case .create(let newPost):
                return (newPost)
            }
        }()
        
        let URLRequest = NSMutableURLRequest(url: url)
        
        let encoding = Alamofire.ParameterEncoding.JSON
        let (encodedRequest, _) = encoding.encode(URLRequest, parameters: params)
        
        encodedRequest.HTTPMethod = method.rawValue
        
        return encodedRequest
    }
}*/
