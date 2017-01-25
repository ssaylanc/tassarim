//
//  TassRouter.swift
//  tassarim
//
//  Created by saylanc on 15/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import Foundation
import Alamofire

enum TassRouter: URLRequestConvertible {
    static let baseURLString = "https://api.dribbble.com/v1/"
    
    case Get(Int)
    case Create([String: AnyObject])
    case Delete(Int)
    /*case
    case LoadAuthUSer()
    case isAuthenticated()
    case LoadUserFollowingShots()
    case LoadShots()
    */
    
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .Get:
                return .GET
            case .Create:
                return .POST
            case .Delete:
                return .DELETE
            //case .LoadAuthUSer():
             //   return .GET
            }
        }
        let url:NSURL = {
            // build up and return the URL for each endpoint
            let relativePath:String?
            switch self {
            case .Get(let postNumber):
                relativePath = "posts/\(postNumber)"
            case .Create:
                relativePath = "posts"
            case .Delete(let postNumber):
                relativePath = "posts/\(postNumber)"
            }
            
            var URL = NSURL(string: TassRouter.baseURLString)!
            if let relativePath = relativePath {
                URL = URL.URLByAppendingPathComponent(relativePath)
            }
            return URL
        }()
        
        let params: ([String: AnyObject]?) = {
            switch self {
            case .Get, .Delete:
                return (nil)
            case .Create(let newPost):
                return (newPost)
            }
        }()
        
        let URLRequest = NSMutableURLRequest(URL: url)
        
        let encoding = Alamofire.ParameterEncoding.JSON
        let (encodedRequest, _) = encoding.encode(URLRequest, parameters: params)
        
        encodedRequest.HTTPMethod = method.rawValue
        
        return encodedRequest
    }
}
