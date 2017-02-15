//
//  ProfileViewController.swift
//  tassarim
//
//  Created by saylanc on 24/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import OAuthSwift
import SafariServices

@available(iOS 9.0, *)
class ProfileViewController: UIViewController/*, UICollectionViewDataSource, UICollectionViewDelegate*/ {
    
    var safariViewController: SFSafariViewController?
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var bucketsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var webAddrView: UIView!
    @IBOutlet weak var webAddressLabel: UILabel!
    @IBAction func webButtonDidTouch(_ sender: AnyObject) {
    }
    
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBAction func twitterButtonDidTouch(_ sender: AnyObject) {
    }
    
    @IBOutlet weak var twitterButtonDidTouch: UIButton!
    @IBAction func logoutButtonDidTouch(_ sender: AnyObject) {
        if data != nil {
            KeychainHelper.delete("dribbble_access_token")
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let shotsVC = mainStoryBoard.instantiateViewController(withIdentifier: "MainVC")
            self.present(shotsVC, animated: true, completion: nil)
        }else{
        print("text")
        }
    }
    @IBAction func followingButtonDidTouch(_ sender: AnyObject) {
    }
    @IBAction func followersButtonDidTouch(_ sender: AnyObject) {
    }
    @IBAction func likesButtonDidTouch(_ sender: AnyObject) {
    }
    @IBOutlet weak var bucketsButtonDidTouch: UIButton!
    
    var user: [String:JSON]? = [:]
    var following: [JSON]? = []
    var followers: [JSON]? = []
    var data: Data!
    var token: String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        data = KeychainHelper.load("dribbble_access_token")
        
        print("data: \(data)")
        
        if data != nil {
            token = KeychainHelper.NSDATAtoString(data!)
        }
        
        if token.isEmpty == true {
            //self.doOAuthDribbble()
            //self.performSegueWithIdentifier("SignInSegue", sender: self)
        }
        else {
            self.logoutButton.titleLabel!.text = "Logout"
            /*let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let shotsVC = mainStoryBoard.instantiateViewControllerWithIdentifier("ShotsVC")
             self.presentViewController(shotsVC, animated: true, completion: nil)*/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileView.layer.cornerRadius = 10
        //self.profileView.clipsToBounds = true
        self.profileView.layer.shadowColor = UIColor.black.cgColor
        self.profileView.layer.shadowOpacity = 0.2
        self.profileView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.profileView.layer.shadowRadius = 2
        DribbbleAPI.sharedInstance.loadAuthUser { (user) in
            if let data = user.dictionaryValue as [String:JSON]?{
                self.user = data
                if let urlAvatar = self.user?["avatar_url"]{
                    let url = URL(string: urlAvatar.stringValue)
                    self.avatarImage.hnk_setImage(from: url!)
                    self.avatarImage.layer.cornerRadius = 30
                    self.avatarImage.clipsToBounds = true
                }
                self.nameLabel.text = self.user?["name"]?.string
                
                if let followingInt: Int = self.user?["followings_count"]?.int {
                    let followingString: String = String(followingInt)
                    self.followingCountLabel.text = followingString
                }
                
                if let followersInt: Int = self.user?["followers_count"]?.int {
                    let followersString: String = String(followersInt)
                    self.followersCountLabel.text = followersString
                }
                
                if let bucketsInt: Int = self.user?["buckets_count"]?.int {
                    let bucketsString: String = String(bucketsInt)
                    self.bucketsCountLabel.text = bucketsString
                }
                
                if let likesInt: Int = self.user?["likes_count"]?.int {
                    let likesString: String = String(likesInt)
                    self.likesCountLabel.text = likesString
                }
            }
        }
    }    
}
