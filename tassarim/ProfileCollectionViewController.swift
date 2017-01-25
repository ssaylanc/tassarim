//
//  ProfileCollectionViewController.swift
//  tassarim
//
//  Created by saylanc on 18/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import SDWebImage
import ChameleonFramework

class ProfileCollectionViewController: UICollectionViewController {

    var activityIndicatorView : NVActivityIndicatorView!
    var user: [String:JSON]? = [:]
    var likedShots: [JSON]? = []
    var shots: [JSON]? = []
    var buckets: [JSON]? = []
    var followers: [JSON]? = []
    var followee: [JSON]? = []
    var selectedIndex: Int! = 0
    var userName: String!
    var avatarImageURL: NSURL!
    var whichUser: String!
    var myView : UIView!
    var firstTimeLoad: Bool! = true
    var userType: String! = ""
    
    let colors = [UIColor(rgba: "#1abc9c"), UIColor(rgba: "#f1c40f"), UIColor(rgba: "#3498db"), UIColor(rgba: "#e74c3c"), UIColor(rgba: "#9b59b6"), UIColor(rgba: "#95a5a6"), UIColor(rgba: "#16a085"), UIColor(rgba: "#f39c12"), UIColor(rgba: "#2980b9"), UIColor(rgba: "#c0392b"), UIColor(rgba: "#8e44ad"), UIColor(rgba: "#bdc3c7"), UIColor(rgba: "#27ae60"), UIColor(rgba: "#d35400"), UIColor(rgba: "#2c3e50"), UIColor(rgba: "#3498db"), UIColor(rgba: "#e67e22"), UIColor(rgba: "#7f8c8d"), UIColor(rgba: "#1abc9c"), UIColor(rgba: "#7f8c8d")]
    
    private func addActivityIndicator() {
        let frame = CGRect(x: collectionView!.center.x - 40 / 2, y: collectionView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.LineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.whiteColor())
        if self.firstTimeLoad == true {
            myView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView!.frame.width, height: collectionView!.frame.height))
            self.view.addSubview(myView)
            myView.backgroundColor = UIColor(rgba: "#F45081")
            view.addSubview(myView)
            if let activityIndicatorView = activityIndicatorView {
                myView.addSubview(activityIndicatorView)
            }
        }else {
            if let activityIndicatorView = activityIndicatorView {
                view.addSubview(activityIndicatorView)
            }
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
                    self.myView.removeFromSuperview()
                    indicator.removeFromSuperview()
            })
        }
    }
    
    func loadAuthUser(){
        DribbbleAPI.sharedInstance.loadAuthUser { (user) in
            if let data = user.dictionaryValue as [String:JSON]?{
                self.user = data
                self.userName = self.user?["name"]?.string
                if let urlAvatar = self.user?["avatar_url"]{
                   self.avatarImageURL = NSURL(string: urlAvatar.stringValue)
                }
                self.stopActivityIndicatorView()
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "SelectedSegment", label: "loadAuthUser", value: 1)

            }
        }
    }
    
    func loadFollowee() {
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadUserFollowing { (followee) in
            if let data = followee.arrayValue as [JSON]?{
                self.followee = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "SelectedSegment", label: "loadFollowee", value: 1)
            }
        }
    }
    
    func loadFollowers() {
        self.firstTimeLoad = false
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadUserFollowers { (followers) in
            if let data = followers.arrayValue as [JSON]?{
                self.followers = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "SelectedSegment", label: "loadFollowers", value: 1)
            }
        }
    }
    
    func loadLikedShots(){
        self.firstTimeLoad = false
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadUserLikes { (likes) in
            if let data = likes.arrayValue as [JSON]?{
                self.likedShots = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "SelectedSegment", label: "loadLikedShots", value: 1)
            }
        }

    }
    
    func loadAuthUserShots(){
        self.firstTimeLoad = false
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadAuthUserShots { (shots) in
            if let data = shots.arrayValue as [JSON]?{
                self.shots = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "SelectedSegment", label: "loadAuthUserShots", value: 1)
            }
        }
    }
    
    func loadBucketList(){
        self.firstTimeLoad = false
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.listUsersBuckets{(buckets) in
            if let data = buckets.arrayValue as [JSON]? {
                self.buckets = data
                print(data)
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "showBucket", label: "bucket", value: 1)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#F45081")
        let button = UIButton()
        button.frame = CGRectMake(0, 0, 20, 20)
        button.setImage(UIImage(named: "ui-signout"), forState: .Normal)
        button.addTarget(self, action: #selector(ProfileCollectionViewController.logout), forControlEvents: UIControlEvents.TouchUpInside)
        let barButton = UIBarButtonItem()
        barButton.customView = button
        self.navigationItem.rightBarButtonItem = barButton
        
        //remove hairline under the navbar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        self.loadAuthUser()
        self.loadFollowee()
    }
    
    func logout(){
        let data = KeychainHelper.load("dribbble_access_token")
        if data != nil {
            KeychainHelper.delete("dribbble_access_token")
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let shotsVC = mainStoryBoard.instantiateViewControllerWithIdentifier("MainVC")
            self.presentViewController(shotsVC, animated: true, completion: nil)
        }else{
            print("text")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#F45081")
        GAnalytics.sharedInstance.sendScreenTracking("UsersProfileView")
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedIndex == 0 {
            self.whichUser = "followee"
            return self.followee?.count ?? 0
        }else if selectedIndex == 1 {
            self.whichUser = "follower"
            return self.followers?.count ?? 0
        }else if selectedIndex == 2 {
            return self.likedShots?.count ?? 0
        }else if selectedIndex == 3{
            return self.buckets?.count ?? 0
        }else{
            return 0
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if selectedIndex == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCollectionViewCell
            cell.followee = self.followee?[indexPath.row]
            return cell
        }else if selectedIndex == 1 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCollectionViewCell
            cell.follower = self.followers?[indexPath.row]
            return cell
        }else if selectedIndex == 2 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShotCell", forIndexPath: indexPath) as! ProfileCollectionViewCell
            cell.shot = self.likedShots?[indexPath.row]
            return cell
        }else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BucketCell", forIndexPath: indexPath) as! ProfileCollectionViewCell
            cell.bucket = self.buckets?[indexPath.row]
            cell.backgroundImage.backgroundColor = self.colors[indexPath.row % self.colors.count]
            cell.backgroundImage.layer.cornerRadius = 10
            cell.backgroundImage.layer.borderWidth = 2
            cell.backgroundImage.layer.borderColor = UIColor.whiteColor().CGColor
            cell.backgroundImage.clipsToBounds = true
            return cell
        }
    }
    
    func segmentedControlDidChangeSegment(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.selectedIndex = 0
            self.stopActivityIndicatorView()
            self.loadFollowee()
        case 1:
            self.selectedIndex = 1
            self.stopActivityIndicatorView()
            self.loadFollowers()
        case 2:
            self.selectedIndex = 2
            self.stopActivityIndicatorView()
            self.loadLikedShots()
        case 3:
            self.selectedIndex = 3
            self.stopActivityIndicatorView()
            self.loadBucketList()
        default: break
        }
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ProfileHeaderID", forIndexPath: indexPath) as! ProfileHeaderView
        headerView.segmentedControl?.addTarget(self, action: #selector(segmentedControlDidChangeSegment(_:)), forControlEvents: .ValueChanged)
        headerView.userNameLabel.text = userName
        headerView.avatarImage.sd_setImageWithURL(self.avatarImageURL)
        headerView.avatarImage.layer.cornerRadius = 30
        headerView.avatarImage.layer.borderWidth = 2.0
        headerView.avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
        headerView.avatarImage.clipsToBounds = true
        //Not: selectedSegmentIndex collectionview reload yapıldığında index'in ne olduğunu bilemez bu yüzden buraya atadık. tableview'da viewForHeaderInSection içinde kullanabilirsin.
        headerView.segmentedControl.selectedSegmentIndex = selectedIndex
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 14.0)!, forKey: NSFontAttributeName)
        headerView.segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , forState: .Normal)
        headerView.segmentedControl.selectedSegmentIndex = selectedIndex
        headerView.segmentedControl.layer.borderColor = UIColor.whiteColor().CGColor
        headerView.segmentedControl.layer.cornerRadius = 14.5
        headerView.segmentedControl.clipsToBounds = true
        headerView.segmentedControl.layer.borderWidth = 2
        headerView.segmentedControl.tintColor = UIColor.whiteColor()
        if let feInt = self.user?["followings_count"] {
            let feString = String(feInt)
            headerView.followingCount.text = feString
        }
        if let foInt = self.user?["followers_count"] {
            let foString = String(foInt)
            headerView.followersCount.text = foString
        }
        if let likesInt = self.user?["likes_count"] {
            let likesString = String(likesInt)
            headerView.likesCount.text = likesString
        }
        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if selectedIndex == 0 {
            return CGSizeMake(collectionView.frame.width, 80)
        }else if selectedIndex == 1{
            return CGSizeMake(collectionView.frame.width, 80)
        }else if selectedIndex == 2{
            return CGSizeMake(collectionView.frame.width/3, collectionView.frame.width/3)
        }else {
            return CGSizeMake(collectionView.frame.width, 64)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // remove lines between cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch selectedIndex {
        case 0:
            let type = self.followee?[indexPath.row]["followee"]["type"]
            self.userType = type?.string
            print("serdar: \(self.userType)")
            if self.userType == "Team" {
                performSegueWithIdentifier("TeamSegue", sender: indexPath)
            }else if self.userType == "Player"{
                performSegueWithIdentifier("UserSegue", sender: indexPath)
            }
        case 1:
            let type = self.followers?[indexPath.row]["follower"]["type"]
            self.userType = type?.string
            print("serdar: \(self.userType)")
            if self.userType == "Team" {
                performSegueWithIdentifier("TeamSegue", sender: indexPath)
            }else if self.userType == "Player"{
                performSegueWithIdentifier("UserSegue", sender: indexPath)
            }
        case 2:
            performSegueWithIdentifier("ShotDetailSegue", sender: indexPath)
        case 3:
            performSegueWithIdentifier("BucketSegue", sender: indexPath)
        default: break
        }
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShotDetailSegue"{
            let toView = segue.destinationViewController as! ShotDetailViewController
            let indexPath = sender as! NSIndexPath
            guard let shotID = self.shots?[indexPath.row]["id"].int else {return}
            toView.shotID = shotID
        }
        if segue.identifier == "UserSegue"{
            if self.whichUser == "followee"{
                let toView = segue.destinationViewController as! UserCollectionViewController
                let indexPath = sender as! NSIndexPath
                let userID = self.followee?[indexPath.row]["followee"]["id"].int
                toView.userID = userID
                self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#798BF8")
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }else {
                let toView = segue.destinationViewController as! UserCollectionViewController
                let indexPath = sender as! NSIndexPath
                let userID = self.followers?[indexPath.row]["follower"]["id"].int
                toView.userID = userID
                self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#798BF8")
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }
        }
        
        if segue.identifier == "TeamSegue"{
            if self.whichUser == "followee"{
                let toView = segue.destinationViewController as! TeamCollectionViewController
                let indexPath = sender as! NSIndexPath
                let userID = self.followee?[indexPath.row]["followee"]["id"].int
                toView.userID = userID
                self.navigationController?.title = self.followee?[indexPath.row]["followee"]["username"].string
                self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#FFC27E")
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }else {
                let toView = segue.destinationViewController as! TeamCollectionViewController
                let indexPath = sender as! NSIndexPath
                let userID = self.followers?[indexPath.row]["follower"]["id"].int
                toView.userID = userID
                self.navigationController?.title = self.followers?[indexPath.row]["follower"]["username"].string
                self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#FFC27E")
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }
        }
        
        if segue.identifier == "BucketSegue"{
            let toView = segue.destinationViewController as! ProjectShotsCollectionViewController
            let indexPath = sender as! NSIndexPath
            let bucketID = self.buckets?[indexPath.row]["id"].int
            toView.isBucket = true
            toView.bucketID = bucketID
            toView.bucketTitle = self.buckets?[indexPath.row]["name"].string
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}
