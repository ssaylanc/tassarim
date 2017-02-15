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
    var avatarImageURL: URL!
    var whichUser: String!
    var myView : UIView!
    var firstTimeLoad: Bool! = true
    var userType: String! = ""
    
    let colors = [UIColor("#1abc9c"), UIColor("#f1c40f"), UIColor("#3498db"), UIColor("#e74c3c"), UIColor("#9b59b6"), UIColor("#95a5a6"), UIColor("#16a085"), UIColor("#f39c12"), UIColor("#2980b9"), UIColor("#c0392b"), UIColor("#8e44ad"), UIColor("#bdc3c7"), UIColor("#27ae60"), UIColor("#d35400"), UIColor("#2c3e50"), UIColor("#3498db"), UIColor("#e67e22"), UIColor("#7f8c8d"), UIColor("#1abc9c"), UIColor("#7f8c8d")]
    
    fileprivate func addActivityIndicator() {
        let frame = CGRect(x: collectionView!.center.x - 40 / 2, y: collectionView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.lineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.white)
        if self.firstTimeLoad == true {
            myView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView!.frame.width, height: collectionView!.frame.height))
            self.view.addSubview(myView)
            myView.backgroundColor = UIColor("#F45081")
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
                   self.avatarImageURL = URL(string: urlAvatar.stringValue)
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
        self.navigationController?.navigationBar.barTintColor = UIColor("#F45081")
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.setImage(UIImage(named: "ui-signout"), for: UIControlState())
        button.addTarget(self, action: #selector(ProfileCollectionViewController.logout), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem()
        barButton.customView = button
        self.navigationItem.rightBarButtonItem = barButton
        
        //remove hairline under the navbar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
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
            let shotsVC = mainStoryBoard.instantiateViewController(withIdentifier: "MainVC")
            self.present(shotsVC, animated: true, completion: nil)
        }else{
            print("text")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor("#F45081")
        GAnalytics.sharedInstance.sendScreenTracking("UsersProfileView")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectedIndex == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCollectionViewCell
            cell.followee = self.followee?[indexPath.row]
            return cell
        }else if selectedIndex == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCollectionViewCell
            cell.follower = self.followers?[indexPath.row]
            return cell
        }else if selectedIndex == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShotCell", for: indexPath) as! ProfileCollectionViewCell
            cell.shot = self.likedShots?[indexPath.row]
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BucketCell", for: indexPath) as! ProfileCollectionViewCell
            cell.bucket = self.buckets?[indexPath.row]
            cell.backgroundImage.backgroundColor = self.colors[indexPath.row % self.colors.count]
            cell.backgroundImage.layer.cornerRadius = 10
            cell.backgroundImage.layer.borderWidth = 2
            cell.backgroundImage.layer.borderColor = UIColor.white.cgColor
            cell.backgroundImage.clipsToBounds = true
            return cell
        }
    }
    
    func segmentedControlDidChangeSegment(_ segmentedControl: UISegmentedControl) {
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileHeaderID", for: indexPath) as! ProfileHeaderView
        headerView.segmentedControl?.addTarget(self, action: #selector(segmentedControlDidChangeSegment(_:)), for: .valueChanged)
        headerView.userNameLabel.text = userName
        headerView.avatarImage.sd_setImage(with: self.avatarImageURL)
        headerView.avatarImage.layer.cornerRadius = 30
        headerView.avatarImage.layer.borderWidth = 2.0
        headerView.avatarImage.layer.borderColor = UIColor.white.cgColor
        headerView.avatarImage.clipsToBounds = true
        //Not: selectedSegmentIndex collectionview reload yapıldığında index'in ne olduğunu bilemez bu yüzden buraya atadık. tableview'da viewForHeaderInSection içinde kullanabilirsin.
        headerView.segmentedControl.selectedSegmentIndex = selectedIndex
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 14.0)!, forKey: NSFontAttributeName as NSCopying)
        headerView.segmentedControl.setTitleTextAttributes(attr as! [AnyHashable: Any] , for: UIControlState())
        headerView.segmentedControl.selectedSegmentIndex = selectedIndex
        headerView.segmentedControl.layer.borderColor = UIColor.white.cgColor
        headerView.segmentedControl.layer.cornerRadius = 14.5
        headerView.segmentedControl.clipsToBounds = true
        headerView.segmentedControl.layer.borderWidth = 2
        headerView.segmentedControl.tintColor = UIColor.white
        if let feInt = self.user?["followings_count"] {
            let feString = String(describing: feInt)
            headerView.followingCount.text = feString
        }
        if let foInt = self.user?["followers_count"] {
            let foString = String(describing: foInt)
            headerView.followersCount.text = foString
        }
        if let likesInt = self.user?["likes_count"] {
            let likesString = String(describing: likesInt)
            headerView.likesCount.text = likesString
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if selectedIndex == 0 {
            return CGSize(width: collectionView.frame.width, height: 80)
        }else if selectedIndex == 1{
            return CGSize(width: collectionView.frame.width, height: 80)
        }else if selectedIndex == 2{
            return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.width/3)
        }else {
            return CGSize(width: collectionView.frame.width, height: 64)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // remove lines between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch selectedIndex {
        case 0:
            let type = self.followee?[indexPath.row]["followee"]["type"]
            self.userType = type?.string
            print("serdar: \(self.userType)")
            if self.userType == "Team" {
                performSegue(withIdentifier: "TeamSegue", sender: indexPath)
            }else if self.userType == "Player"{
                performSegue(withIdentifier: "UserSegue", sender: indexPath)
            }
        case 1:
            let type = self.followers?[indexPath.row]["follower"]["type"]
            self.userType = type?.string
            print("serdar: \(self.userType)")
            if self.userType == "Team" {
                performSegue(withIdentifier: "TeamSegue", sender: indexPath)
            }else if self.userType == "Player"{
                performSegue(withIdentifier: "UserSegue", sender: indexPath)
            }
        case 2:
            performSegue(withIdentifier: "ShotDetailSegue", sender: indexPath)
        case 3:
            performSegue(withIdentifier: "BucketSegue", sender: indexPath)
        default: break
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShotDetailSegue"{
            let toView = segue.destination as! ShotDetailViewController
            let indexPath = sender as! IndexPath
            guard let shotID = self.shots?[indexPath.row]["id"].int else {return}
            toView.shotID = shotID
        }
        if segue.identifier == "UserSegue"{
            if self.whichUser == "followee"{
                let toView = segue.destination as! UserCollectionViewController
                let indexPath = sender as! IndexPath
                let userID = self.followee?[indexPath.row]["followee"]["id"].int
                toView.userID = userID
                self.navigationController?.navigationBar.barTintColor = UIColor("#798BF8")
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }else {
                let toView = segue.destination as! UserCollectionViewController
                let indexPath = sender as! IndexPath
                let userID = self.followers?[indexPath.row]["follower"]["id"].int
                toView.userID = userID
                self.navigationController?.navigationBar.barTintColor = UIColor("#798BF8")
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }
        }
        
        if segue.identifier == "TeamSegue"{
            if self.whichUser == "followee"{
                let toView = segue.destination as! TeamCollectionViewController
                let indexPath = sender as! IndexPath
                let userID = self.followee?[indexPath.row]["followee"]["id"].int
                toView.userID = userID
                self.navigationController?.title = self.followee?[indexPath.row]["followee"]["username"].string
                self.navigationController?.navigationBar.barTintColor = UIColor("#FFC27E")
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }else {
                let toView = segue.destination as! TeamCollectionViewController
                let indexPath = sender as! IndexPath
                let userID = self.followers?[indexPath.row]["follower"]["id"].int
                toView.userID = userID
                self.navigationController?.title = self.followers?[indexPath.row]["follower"]["username"].string
                self.navigationController?.navigationBar.barTintColor = UIColor("#FFC27E")
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }
        }
        
        if segue.identifier == "BucketSegue"{
            let toView = segue.destination as! ProjectShotsCollectionViewController
            let indexPath = sender as! IndexPath
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
