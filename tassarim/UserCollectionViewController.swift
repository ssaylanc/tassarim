//
//  UserCollectionViewController.swift
//  tassarim
//
//  Created by saylanc on 07/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import SDWebImage
import RandomColorSwift
import ChameleonFramework

class UserCollectionViewController: UICollectionViewController {
    
    var userID: Int!
    var shots: [SwiftyJSON.JSON]? = []
    var members: [SwiftyJSON.JSON]? = []
    var projects: [SwiftyJSON.JSON]? = []
    var user: [String:SwiftyJSON.JSON]? = [:]
    var activityIndicatorView : NVActivityIndicatorView!
    var isShotsLoading: Bool = true
    var myView : UIView!
    var firstTimeLoad: Bool! = true
    var selectedIndex: Int! = 0
    var count = 99
    var page = 1
    
    let colors = [UIColor(rgba: "#1abc9c"), UIColor(rgba: "#f1c40f"), UIColor(rgba: "#3498db"), UIColor(rgba: "#e74c3c"), UIColor(rgba: "#9b59b6"), UIColor(rgba: "#95a5a6"), UIColor(rgba: "#16a085"), UIColor(rgba: "#f39c12"), UIColor(rgba: "#2980b9"), UIColor(rgba: "#c0392b"), UIColor(rgba: "#8e44ad"), UIColor(rgba: "#bdc3c7"), UIColor(rgba: "#27ae60"), UIColor(rgba: "#d35400"), UIColor(rgba: "#2c3e50"), UIColor(rgba: "#3498db"), UIColor(rgba: "#e67e22"), UIColor(rgba: "#7f8c8d"), UIColor(rgba: "#1abc9c"), UIColor(rgba: "#7f8c8d")]
    
    private func addActivityIndicator() {
        let frame = CGRect(x: collectionView!.center.x - 40 / 2, y: collectionView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.LineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.whiteColor())
        if self.firstTimeLoad == true {
            myView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView!.frame.width, height: collectionView!.frame.height))
            self.view.addSubview(myView)
            myView.backgroundColor = UIColor(rgba: "#798BF8")
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
        isShotsLoading = true
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
                    //self.collectionView?.reloadData()
                    self.myView.removeFromSuperview()
                    indicator.removeFromSuperview()
            })
        }
        isShotsLoading = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startActivityIndicatorView()
        self.loadUser()
        self.loadUserShots()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor(rgba: "#798BF8")
        GAnalytics.sharedInstance.sendScreenTracking("UserView, ID:\(userID)")
    }

    func showMore() {
        if DribbbleAPI.sharedInstance.isAuthenticated(){
            performSegueWithIdentifier("showMoreSegue", sender: self)
            GAnalytics.sharedInstance.trackAction("BUTTON", action: "openProfileSegue", label: "openProfileSegue", value: 1)
        }
    }
    
    var userName: String!
    var location: String!
    var avatarImageURL: NSURL!
    var isPro: Bool!
    var isProLabel: String!
    var team: String!
    var teamCount: Int!
    var teamID: Int!

    @IBOutlet weak var coverImage: UIImageView!
    func loadUser() {
        DribbbleAPI.sharedInstance.loadUser(userID) { (user) in
            if let data = user.dictionaryValue as [String:SwiftyJSON.JSON]? {
                self.user = data
                self.teamID = self.user?["id"]!.int
                self.userName = self.user?["name"]!.string
                self.title = self.userName
                let loca = self.user?["location"]!.string
                if (loca ?? "").isEmpty {
                    self.location = "No Location"
                }else{
                    self.location = loca
                }
                
                //self.location = self.user?["location"]!.string
                if let urlAvatar = self.user?["avatar_url"]{
                    self.avatarImageURL = NSURL(string: urlAvatar.stringValue)
                }
                let type = self.user?["type"]!.string
                if type! == "Player" {
                    let isPro = self.user?["pro"]!.bool
                    if isPro! == true {
                        self.isProLabel = "PRO"
                    }else{
                        self.isProLabel = ""
                    }
                }else if type! == "Team"{
                    self.team = "Team"
                }
            }
        }
    }
    
    func loadTeamMembers(){
        self.firstTimeLoad = false
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadTeamMembers(teamID) { (members) in
            if let data = members.arrayValue as [JSON]?{
                self.members = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    func loadProjects(){
        self.firstTimeLoad = false
        self.startActivityIndicatorView()
        //colors = randomColors(20, hue: .Value(120), luminosity: .Random)
        //colors = randomColorsCount(99, hue: .Monochrome, luminosity: .Light)
        DribbbleAPI.sharedInstance.loadProjects(teamID) { (projects) in
            if let data = projects.arrayValue as [JSON]?{
                self.projects = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    func loadUserShots(page: Int = 1){
        self.firstTimeLoad = false
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadUserShots(userID, page: page) { (userShots) in
            if let data = userShots.arrayValue as [SwiftyJSON.JSON]?{
                self.shots = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if selectedIndex == 0 { return self.shots?.count ?? 0}
        else if selectedIndex == 1 { return self.projects?.count ?? 0}
        else { return self.projects?.count ?? 0}
    }

    func segmentedControlDidChangeSegment(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.selectedIndex = 0
            self.stopActivityIndicatorView()
            self.loadUserShots()
        case 1:
            self.selectedIndex = 1
            self.stopActivityIndicatorView()
            self.loadProjects()
        case 2:
            self.selectedIndex = 2
            self.stopActivityIndicatorView()
            self.loadProjects()
        
        default: break
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if selectedIndex == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShotCell", forIndexPath: indexPath) as! UserShotsCollectionViewCell
            cell.shot = self.shots?[indexPath.row]
            
            /*let rowsToLoadFromBottom = 3;
            let rowsLoaded = self.shots!.count
            if (!self.isShotsLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)))
            {
                page += 1
                self.startActivityIndicatorView()
                loadUserShots(page)
            }*/
            
            return cell
        }else if selectedIndex == 1 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProjectCell", forIndexPath: indexPath) as! UserShotsCollectionViewCell
            cell.projects = self.projects?[indexPath.row]
            //cell.backgroundImage.backgroundColor = self.colors[indexPath.row % self.colors.count]
            cell.backgroundImage.backgroundColor = self.colors[indexPath.row % self.colors.count]
            cell.backgroundImage.layer.cornerRadius = 10
            cell.backgroundImage.layer.borderWidth = 2
            cell.backgroundImage.layer.borderColor = UIColor.whiteColor().CGColor
            cell.backgroundImage.clipsToBounds = true
            
            cell.projectIcon.backgroundColor = UIColor.clearColor()
            cell.projectIcon.layer.cornerRadius = 15
            cell.projectIcon.clipsToBounds = true
            cell.projectIcon.layer.borderWidth = 2
            cell.projectIcon.layer.borderColor = UIColor.whiteColor().CGColor

            return cell

        }else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProjectCell", forIndexPath: indexPath) as! UserShotsCollectionViewCell
            cell.projects = self.projects?[indexPath.row]
            return cell
        }
    }

    func segmentedControlDidChangeSegmend(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.selectedIndex = 0
            self.stopActivityIndicatorView()
            self.loadUserShots()
        case 1:
            self.selectedIndex = 1
            self.stopActivityIndicatorView()
            self.loadProjects()
        case 2:
            self.selectedIndex = 2
            self.stopActivityIndicatorView()
            self.loadProjects()
        default: break
        }
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerID", forIndexPath: indexPath) as! HeaderView
        headerView.segmentedControl?.addTarget(self, action: #selector(segmentedControlDidChangeSegmend(_:)), forControlEvents: .ValueChanged)
        headerView.locationLabel.text = location
        headerView.avatarImageURL = avatarImageURL
        headerView.userID = userID
        //headerView.avatarImage.hnk_setImageFromURL(avatarImageURL)
        headerView.avatarImage.sd_setImageWithURL(avatarImageURL, placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
        headerView.avatarImage.layer.cornerRadius = 30
        headerView.avatarImage.layer.borderWidth = 2.0
        headerView.avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
        headerView.avatarImage.clipsToBounds = true
        headerView.checkIfFollowing(userID)
        
        headerView.segmentedControl.selectedSegmentIndex = selectedIndex
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, forKey: NSFontAttributeName)
        headerView.segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , forState: .Normal)
        headerView.segmentedControl.layer.borderColor = UIColor.whiteColor().CGColor
        headerView.segmentedControl.layer.cornerRadius = 14.5
        headerView.segmentedControl.clipsToBounds = true
        headerView.segmentedControl.layer.borderWidth = 2
        headerView.segmentedControl.tintColor = UIColor.whiteColor()
        //headerView.setAvatar(avatarImageURL)
        return headerView
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if isShotsLoading{
            return CGSize(width: 0, height: 0)
        }else{
            return CGSize(width: view.frame.width, height: 203)
        }
    }*/
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if selectedIndex == 0 {
            return CGSizeMake(collectionView.frame.width/3, collectionView.frame.width/3)
        }else if selectedIndex == 1{
            return CGSizeMake(collectionView.frame.width, 70)
        }else{
            return CGSizeMake(collectionView.frame.width/3, collectionView.frame.width/3)
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
            performSegueWithIdentifier("ShotDetailSegue", sender: indexPath)
        case 1:
            performSegueWithIdentifier("ProjectShotsSegue", sender: indexPath)
        case 2:
            performSegueWithIdentifier("ProjectSegue", sender: indexPath)
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
        /*if segue.identifier == "showMoreSegue"{
            let toView = segue.destinationViewController as! MoreCollectionViewController
            guard let teamID = self.user?["id"]!.int else {return}
            toView.teamID = teamID
        }*/
        if segue.identifier == "MemberSegue"{}
        if segue.identifier == "ProjectShotsSegue"{
            let indexPath = sender as! NSIndexPath
            let toView = segue.destinationViewController as! ProjectShotsCollectionViewController
            toView.projectID = self.projects?[indexPath.row]["id"].int
            toView.projectTitle = self.projects?[indexPath.row]["name"].string
            toView.isBucket = false
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}