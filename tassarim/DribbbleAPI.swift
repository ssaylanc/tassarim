//
//  DribbbleAPI.swift
//  tassarim
//
//  Created by saylanc on 29/10/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DribbbleAPI {
    
    static let sharedInstance = DribbbleAPI()
    var authToken: String! = ""
    var token: String! = ""
    var cacheResponse: Bool = false
    
    func isAuthenticated() -> Bool {
        //authToken = KeychainHelper.NSDATAtoString(KeychainHelper.load("dribbble_access_token")!)
        let data = KeychainHelper.load("dribbble_access_token")
        print("data: \(data)")
        
        if data != nil {
            token = KeychainHelper.NSDATAtoString(data!)
            print("1: AuthToken: \(token)")
            return true
        }else{
            token = URList.access_token
            print("2: URLToken: \(token)")
            return false
        }
    }
    
    func loadAuthUser(callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/user"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let user = JSON(value)
                callback(user)
            }
        }
    }
    
    func loadTeamMembers(teamID: Int, callback: (JSON) -> Void){
        self.isAuthenticated()
        let baseURL = "https://api.dribbble.com/v1/teams/\(teamID)/members"
        let parameters: [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, baseURL, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let teamMembers = JSON(value)
                callback(teamMembers)
            }
        }
    
    }
    
    func loadUserFollowingShots(callback: (JSON) -> Void){
        self.isAuthenticated()
        let baseURL = "https://api.dribbble.com/v1/user/following/shots"
        let parameters: [String : AnyObject] = ["access_token": token, "per_page": 30, "page": 1]
        Alamofire.request(.GET, baseURL, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let shots = JSON(value)
                callback(shots)
            }
        }
    }
    
    func loadUserFollowers(callback: (JSON) -> Void){
        self.isAuthenticated()
        let baseURL = "https://api.dribbble.com/v1/user/followers"
        let parameters: [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, baseURL, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let followers = JSON(value)
                callback(followers)
            }
        }
    }
    
    func loadUserFollowing(callback: (JSON) -> Void){
        self.isAuthenticated()
        let baseURL = "https://api.dribbble.com/v1/user/following"
        let parameters: [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, baseURL, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let users = JSON(value)
                callback(users)
            }
        }
    }
    
    func loadUserLikes(callback: (JSON) -> Void){
        self.isAuthenticated()
        let baseURL = "https://api.dribbble.com/v1/user/likes"
        let parameters: [String : AnyObject] = ["access_token": token, "per_page": 100]
        Alamofire.request(.GET, baseURL, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let likes = JSON(value)
                callback(likes)
            }
        }
    }

    func loadAuthUserShots(callback: (JSON) -> Void){
        self.isAuthenticated()
        let baseURL = "https://api.dribbble.com/v1/user/shots"
        let parameters: [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, baseURL, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let shots = JSON(value)
                callback(shots)
            }
        }
    }

    
    func loadShots (list_name: String, page: Int, shotsPerPage: Int = 42, callback: (JSON) -> Void){
        //let baseURL = URList.shots_url + URList.url_token + URList.access_token + "&per_page=\(shotsPerPage)" + "&page=\(page)"
        self.isAuthenticated()
        let baseURL = "https://api.dribbble.com/v1/shots?"
        let parameters : [String : AnyObject] = ["access_token": token, "per_page": shotsPerPage, "page": page, "list": list_name]
        Alamofire.request(.GET, baseURL, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let shots = JSON(value)
                callback(shots)
            }
        }
    }
    
    func loadShot(shotID: Int, callback: (JSON) -> Void) {
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/shots/" + "\(shotID)"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
          /*  if !response.result.isFailure && !self.cacheResponse {
                do {
                    let json = response.result.value
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(json!, options: NSJSONWritingOptions.PrettyPrinted)
                    CacheHelper.sharedInstance.cacheJSONResponse(url, data: jsonData)
                    self.cacheResponse = true
                    let shot = JSON(json!)
                    callback(shot)
                    
                } catch let error as NSError {
                    print(error)
                }
                
            } else if !response.result.isFailure && self.cacheResponse {
                CacheHelper.sharedInstance.fetchCachedDataResponse(url, onSuccess: { (data) in
                    do {
                        let decoded = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        //self.parseJSONCacheSuccess(decoded)
                        print("decoded: \(decoded)")
                        
                        /*GTUtils.runWithDelay(0.5, block: { // Delay request so that client has time to process cache.
                            requestBlock()
                        })*/
                    } catch let error as NSError {
                        print(error)
                       // GTLog.logError(GTLogConstants.Tag, message: "Error fetching cached response for request:\nUrl: \(URLString)\nError: \(error)\n\n", forceLog: true)
                    }
                    }, onError: {(error) in
                       //GTLog.logError(GTLogConstants.Tag, message: "Error fetching cached response for request:\nUrl: \(URLString)\nError: \(error)\n\n", forceLog: true)
                        
                      /*  GTUtils.runWithDelay(0.5, block: { // Delay request so that client has time to process cache.
                            requestBlock()
                        })*/
                })
            }*/
            
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let shot = JSON(value)
                callback(shot)
            }
        }
    }
    
    func loadAttachments(shotID: Int, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/shots/" + "\(shotID)/attachments"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let shot = JSON(value)
                callback(shot)
            }
        }
    
    }
    
    func loadComments (shotID: Int, callback: (JSON) -> Void) {
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/shots/" + "\(shotID)/comments"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let shots = JSON(value)
                callback(shots)
            }
        }
    }
    
    func loadUser (userID: Int, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/users/\(userID)?"
        //let url = "https://api.dribbble.com/v1/user/699467?"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let user = JSON(value)
                callback(user)
            }
        }
    }
    
    func loadProjects(userID: Int!, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/users/\(userID)/projects"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let projects = JSON(value)
                callback(projects)
            }
        }
    }
    
    func loadShotsofProject(projectID: Int!, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/projects/\(projectID)/shots"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let shots = JSON(value)
                callback(shots)
            }
        }
    }
    
    func loadAuthProjects(userID: Int!, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/users/projects"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let projects = JSON(value)
                callback(projects)
            }
        }
    }
    
    func loadUserShots(userID: Int, page: Int,  callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/users/\(userID)/shots?"
        let parameters : [String : AnyObject] = ["access_token": token, "page": page, "per_page": 300]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let userShots = JSON(value)
                callback(userShots)
            }
        }
    }
    
    func isLiked(shotID: Int, callback: (Bool) -> Void) {
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/shots/\(shotID)/like"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 404 {
                print("not liked")
                callback(false)
            } else if response.response?.statusCode == 200 {
                print("liked")
                callback(true)
            }
        }
    }
    
    func likeAShot(shotID: Int, callback: (Bool) -> Void) {
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/shots/\(shotID)/like"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.POST, url, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("liked")
                callback(true)
            } else {
                print("liked error")
                callback(false)
            }
        }
    }
    
    func unlikeAShot(shotID: Int, callback: (Bool) -> Void) {
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/shots/\(shotID)/like"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.DELETE, url, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("unliked")
                callback(true)
            } else {
                print("unliked error")
                callback(false)
            }
        }
    }
    
    //user follow actions
    func isUserFollowed(userID: Int, callback: (Bool) -> Void) {
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/user/following/\(userID)"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 204 {
                print("following")
                callback(true)
            } else if response.response?.statusCode == 404 {
                print("not following")
                callback(false)
            }

        }
    }
    
    func followUser(userID: Int, callback: (Bool) -> Void) {
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/users/\(userID)/follow"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.PUT, url, parameters: parameters).responseJSON { response in
            print(response.response?.statusCode)
            print(response.response)
            if response.response?.statusCode == 204 {
                print("followed")
                callback(true)
            } else {
                print("follow error")
                callback(false)
            }
        }
    }
    
    func unFollowUser(userID: Int, callback: (Bool) -> Void) {
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/users/\(userID)/follow"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.DELETE, url, parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 204 {
                print("unfollowed")
                callback(true)
            } else {
                print("unfollow error")
                callback(false)
            }
        }
    }
    
    func listFollowersOfAUser(userID: Int, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/users/\(userID)/followers"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let followers = JSON(value)
                callback(followers)
            }
        }
    }
    
    func listFollowersOfAuthUser(userID: Int, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/users/followers"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let followers = JSON(value)
                callback(followers)
            }
        }
    }
    
    //buckets
    func listBucketsOfShot(shotID: Int, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/shots/\(shotID)/buckets"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let buckets = JSON(value)
                callback(buckets)
            }
        }
        
    }
    
    func listShotsofBucket(bucketID: Int, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/buckets/\(bucketID)/shots"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let shots = JSON(value)
                callback(shots)
            }
        }
        
    }
    
    func getBucket(bucketID: Int, callback: (JSON) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/buckets/\(bucketID)"
        let parameters : [String : AnyObject] = ["access_token": token]
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            guard response.result.error == nil else {
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                let buckets = JSON(value)
                callback(buckets)
            }
        }
    }
    
    func updateBucket(bucketID: Int, shotID: Int, callback: (Bool) -> Void){
        self.isAuthenticated()
        let url = "https://api.dribbble.com/v1/buckets/\(bucketID)/shots"
        let parameters : [String : AnyObject] = ["access_token": token, "shot_id": shotID]
        Alamofire.request(.PUT, url, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print(response.response?.statusCode)
                print(response.response)
                print("bucket success")
                callback(true)
            } else {
                print("bucket fail")
                callback(false)
            }
        }
    }
    
    func listUsersBuckets(callback: (JSON) -> Void){
        if isAuthenticated() {
            let parameters : [String : AnyObject] = ["access_token": token]
            let url = "https://api.dribbble.com/v1//user/buckets"
            Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
                guard response.result.error == nil else {
                    print("error calling GET on /posts/1")
                    print(response.result.error!)
                    return
                }
                if let value: AnyObject = response.result.value {
                    let buckets = JSON(value)
                    callback(buckets)
                }
            }
        }/*else {
            let parameters : [String : AnyObject] = ["access_token": token]
            let url = "https://api.dribbble.com/v1//users/\(userID)/buckets"
            Alamofire.request(.PUT, url, parameters: parameters).responseJSON { response in
                guard response.result.error == nil else {
                    print("error calling GET on /posts/1")
                    print(response.result.error!)
                    return
                }
                if let value: AnyObject = response.result.value {
                    let buckets = JSON(value)
                    callback(buckets)
                }
            }
        }*/
    }
}

