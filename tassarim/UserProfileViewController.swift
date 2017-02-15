//
//  UserProfileViewController.swift
//  tassarim
//
//  Created by saylanc on 16/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON
import OAuthSwift
import SafariServices

import NVActivityIndicatorView

class UserProfileViewController: UIViewController, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    var safariViewController: SFSafariViewController?
    var activityIndicatorView : NVActivityIndicatorView!
    var user: [String:JSON]? = [:]
    var data: Data!
    var token: String = ""

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

    fileprivate func addActivityIndicator() {
        let frame = CGRect(x: profileTableView!.center.x - 40 / 2, y: profileTableView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.lineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.black)
        
        if let activityIndicatorView = activityIndicatorView {
            view.addSubview(activityIndicatorView)
        }
    }
    
    func startActivityIndicatorView() {
        addActivityIndicator()
        if let indicator = activityIndicatorView {
            indicator.startAnimating()
        }
    }
    
    func stopActivityIndicatorView() {
        if let indicator = activityIndicatorView {
            UIView.animate(
                withDuration: 0.6,
                delay: 0.1,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.0,
                options: [],
                animations: {
                    indicator.alpha = 0
                    indicator.layer.opacity = 0
                    
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
            })
        }
    }

    func loadProfile(){
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadAuthUser { (user) in
            if let data = user.dictionaryValue as [String:JSON]?{
                self.user = data
                self.profileTableView.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        self.profileTableView!.rowHeight = UITableViewAutomaticDimension
        self.profileTableView!.separatorStyle = .none
        self.loadProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        data = KeychainHelper.load("dribbble_access_token")
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! UserProfileTableViewCell
            cell.locationLabel.text = self.user?["name"]?.string
            
            cell.profileView.layer.cornerRadius = 10
            cell.profileView.layer.shadowColor = UIColor.black.cgColor
            cell.profileView.layer.shadowOpacity = 0.2
            cell.profileView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.profileView.layer.shadowRadius = 2
            
            if let urlAvatar = self.user?["avatar_url"]{
                //let url = NSURL(string: urlAvatar.stringValue)
                //cell.avatarImageView.hnk_setImageFromURL(url!)
                cell.avatarImageView.sd_setImage(with: URL(string: urlAvatar.stringValue), placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
                cell.avatarImageView.layer.cornerRadius = 30
                cell.avatarImageView.clipsToBounds = true
            }
            if let followingInt: Int = self.user?["followings_count"]?.int {
                let followingString: String = String(followingInt)
                cell.followingCount.text = followingString
            }
            
            if let followersInt: Int = self.user?["followers_count"]?.int {
                let followersString: String = String(followersInt)
                cell.followersCount.text = followersString
            }
        
            if let bucketsInt: Int = self.user?["buckets_count"]?.int {
                let bucketsString: String = String(bucketsInt)
                cell.bucketsCount.text = bucketsString
            }
            
            if let likesInt: Int = self.user?["likes_count"]?.int {
                let likesString: String = String(likesInt)
                cell.bucketsCount.text = likesString
            }
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! UserProfileTableViewCell
            
            if let abc = self.user?["links"]?.dictionaryValue
            {
                if let ded = abc["web"]?.string {
                    cell.contactAdress.text = ded
                    cell.contactView.layer.cornerRadius = 10
                    cell.contactView.layer.shadowColor = UIColor.black.cgColor
                    cell.contactView.layer.shadowOpacity = 0.2
                    cell.contactView.layer.shadowOffset = CGSize(width: 0, height: 2)
                    cell.contactView.layer.shadowRadius = 2
                }else{
                    cell.contactView.isHidden = true
                }
            }
            /*if (self.user?["links"]) == nil {
                print(self.user?["links"])
                cell.contactView.hidden = true
                //cell.contactAdress.text = web.string
            }else{
                if let webAddr = self.user?["links"]!["web"]{
                    //cell.contactAdress.text = webAddr
                }
            }*/
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterCell", for: indexPath) as! UserProfileTableViewCell
            
            if let abc = self.user?["links"]?.dictionaryValue {
                if let ded = abc["twitter"]?.string{
                
                    cell.twitterLabel.text = ded
                    cell.twitterView.layer.cornerRadius = 10
                    cell.twitterView.layer.shadowColor = UIColor.black.cgColor
                    cell.twitterView.layer.shadowOpacity = 0.2
                    cell.twitterView.layer.shadowOffset = CGSize(width: 0, height: 2)
                    cell.twitterView.layer.shadowRadius = 2
                }else{
                    cell.twitterView.isHidden = true
                }
            }
            cell.selectionStyle = .none
            return cell
        }else {
             let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterCell", for: indexPath) as! UserProfileTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0)
        {
            return 218
        }
        else if(indexPath.row == 1)
        {
            return 30.0
        }
        else if (indexPath.row == 2)
        {
            return 30.0
        }else {
            return 30.0
        }
    }
    
    /*func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }*/

}
