//
//  UserViewController.swift
//  tassarim
//
//  Created by saylanc on 01/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class UserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var isProLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var shots: [JSON]? = []
    var user: [String:JSON]? = [:]
    var userID: Int!
    var activityIndicatorView : NVActivityIndicatorView!
    
    @IBAction func followButtonDidTouch(sender: AnyObject) {
        DribbbleAPI.sharedInstance.isUserFollowed(userID) { (followed) in
            if followed {
                self.unFollowUser()
            }else{
                self.followUser()
            }
        }

    }
    
    func checkIfFollowing(){
        DribbbleAPI.sharedInstance.isUserFollowed(userID) { (followed) in
            if followed {
                self.setFollowingButton(true)
            }else{
                self.setFollowingButton(false)
            }
        }
    }
    
    func followUser(){
        
        DribbbleAPI.sharedInstance.followUser(userID) { (followed) in
            if followed {
                self.followButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
                UIView.animateWithDuration(0.3,
                                           delay: 0.1,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 1,
                                           options: .CurveLinear,
                                           animations: { _ in
                                            self.followButton.transform = CGAffineTransformIdentity
                                            self.setFollowingButton(true)
                    },completion: { _ in}
                )
            }else{
            
            }
        }
    }
    
    func unFollowUser(){
        DribbbleAPI.sharedInstance.unFollowUser(userID) { (unfollowed) in
            if unfollowed {
                self.followButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
                UIView.animateWithDuration(0.3,
                                           delay: 0.1,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 1,
                                           options: .CurveLinear,
                                           animations: { _ in
                                            self.followButton.transform = CGAffineTransformIdentity
                                            self.setFollowingButton(false)
                    },completion: { _ in}
                )
            }else{
            
            }
        }
    }
    
    func setFollowingButton(followed: Bool){
        if followed == true {
            self.followButton.layer.cornerRadius = self.followButton.frame.size.height/2
            self.followButton.layer.backgroundColor = UIColorFromRGB(0xF45081).CGColor
            self.followButton.layer.borderColor = UIColor.clearColor().CGColor
            self.followButton.layer.shadowColor = UIColorFromRGB(0xF45081).CGColor
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.followButton.layer.shadowRadius = 5
            self.followButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }else{
            self.followButton.layer.cornerRadius = self.followButton.frame.size.height/2
            self.followButton.layer.backgroundColor = UIColor.clearColor().CGColor
            self.followButton.layer.borderWidth = 1.0
            self.followButton.layer.borderColor = UIColorFromRGB(0xAAAAAA).CGColor
            self.followButton.layer.shadowColor = UIColorFromRGB(0xAAAAAA).CGColor
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.followButton.layer.shadowRadius = 5
            self.followButton.setTitleColor(UIColorFromRGB(0xAAAAAA), forState: UIControlState.Normal)
        }
    }
    
    private func addActivityIndicator() {
        let frame = CGRect(x: collectionView!.center.x - 40 / 2, y: collectionView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.LineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.blackColor())
        if let activityIndicatorView = activityIndicatorView {
            view.addSubview(activityIndicatorView)
        }
    }
    
    func startActivityIndicatorView() {
        addActivityIndicator()
        if let indicator = activityIndicatorView {
            indicator.startAnimating()
            self.mainView.hidden = true
        }
    }
    
    func stopActivityIndicatorView() {
        if let indicator = activityIndicatorView {
            UIView.animateWithDuration(
                0.6,
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
                    self.mainView.hidden = false
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkIfFollowing()
        
        self.startActivityIndicatorView()
        
        self.profileView.layer.cornerRadius = 10
        self.profileView.layer.shadowColor = UIColor.blackColor().CGColor
        self.profileView.layer.shadowOpacity = 0.4
        self.profileView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.profileView.layer.shadowRadius = 2
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.loadUser()
    }

    func loadUser() {
        DribbbleAPI.sharedInstance.loadUser(userID) { (user) in
            if let data = user.dictionaryValue as [String:JSON]? {
                self.user = data
                self.userNameLabel.text = self.user?["name"]!.string
                self.locationLabel.text = self.user?["location"]!.string
                
                if let urlAvatar = self.user?["avatar_url"]{
                    let url = NSURL(string: urlAvatar.stringValue)
                    self.avatarImage.hnk_setImageFromURL(url!)
                    self.avatarImage.layer.cornerRadius = 30
                    self.avatarImage.layer.borderWidth = 2
                    self.avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
                    self.avatarImage.clipsToBounds = true
                }
                let type = self.user?["type"]!.string
                if type == "player" {
                    let isPro = self.user?["pro"]?.bool
                    if isPro == true {
                        self.isProLabel.text = "PRO"
                    }else{
                        self.isProLabel.text = ""
                    }
                }else if type == "team" {
                    self.isProLabel.text = "TEAM"
                }
            }
            self.stopActivityIndicatorView()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shots?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShotCell", forIndexPath: indexPath) as! UserShotsCollectionViewCell
        cell.shot = self.shots?[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width/3, collectionView.frame.width/3)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // remove lines between cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShotDetailSegue", sender: indexPath)
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShotDetailSegue"{
            let toView = segue.destinationViewController as! ShotDetailViewController
            let indexPath = sender as! NSIndexPath
            guard let shotID = self.shots?[indexPath.row]["id"].int! else {return}
            toView.shotID = shotID
        }
    }
}
