//
//  TeamCollectionViewController.swift
//  tassarim
//
//  Created by saylanc on 08/01/17.
//  Copyright © 2017 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import SDWebImage
import ChameleonFramework

class TeamCollectionViewController: UICollectionViewController {
    
    var userID: Int!
    var shots: [SwiftyJSON.JSON]? = []
    var members: [SwiftyJSON.JSON]? = []
    var projects: [SwiftyJSON.JSON]? = []
    var user: [String:SwiftyJSON.JSON]? = [:]
    var activityIndicatorView : NVActivityIndicatorView!
    var isShotsLoading: Bool = true
    var page = 1
    var myView : UIView!
    var firstTimeLoad: Bool! = true
    var selectedIndex: Int! = 0
    
    let colors = [UIColor("#1abc9c"), UIColor("#f1c40f"), UIColor("#3498db"), UIColor("#e74c3c"), UIColor("#9b59b6"), UIColor("#95a5a6"), UIColor("#16a085"), UIColor("#f39c12"), UIColor("#2980b9"), UIColor("#c0392b"), UIColor("#8e44ad"), UIColor("#bdc3c7"), UIColor("#27ae60"), UIColor("#d35400"), UIColor("#2c3e50"), UIColor("#3498db"), UIColor("#e67e22"), UIColor("#7f8c8d"), UIColor("#1abc9c"), UIColor("#7f8c8d")]
    
    fileprivate func addActivityIndicator() {
        let frame = CGRect(x: collectionView!.center.x - 40 / 2, y: collectionView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.lineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.white)
        if self.firstTimeLoad == true {
            myView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView!.frame.width, height: collectionView!.frame.height))
            self.view.addSubview(myView)
            myView.backgroundColor = UIColor("#FFC27E")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor("#FFC27E")
        GAnalytics.sharedInstance.sendScreenTracking("UserView, ID:\(userID)")
    }
    
    func showMore() {
        if DribbbleAPI.sharedInstance.isAuthenticated(){
            performSegue(withIdentifier: "showMoreSegue", sender: self)
            GAnalytics.sharedInstance.trackAction("BUTTON", action: "openProfileSegue", label: "openProfileSegue", value: 1)
        }
    }
    
    var userName: String!
    var location: String!
    var avatarImageURL: URL!
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
                self.location = self.user?["location"]!.string
                if let urlAvatar = self.user?["avatar_url"]{
                    self.avatarImageURL = URL(string: urlAvatar.stringValue)
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
        DribbbleAPI.sharedInstance.loadProjects(teamID) { (projects) in
            if let data = projects.arrayValue as [JSON]?{
                self.projects = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    func loadUserShots(_ page: Int = 1){
        DribbbleAPI.sharedInstance.loadUserShots(userID, page: page) { (userShots) in
            if let data = userShots.arrayValue as [SwiftyJSON.JSON]?{
                self.shots = data
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if selectedIndex == 0 { return self.shots?.count ?? 0}
        else if selectedIndex == 1 { return self.members?.count ?? 0}
        else { return self.projects?.count ?? 0}
    }
    
    func segmentedControlDidChangeSegment(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.selectedIndex = 0
            self.stopActivityIndicatorView()
            self.loadUserShots()
        case 1:
            self.selectedIndex = 1
            self.stopActivityIndicatorView()
            self.loadTeamMembers()
        case 2:
            self.selectedIndex = 2
            self.stopActivityIndicatorView()
            self.loadProjects()
            
        default: break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectedIndex == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShotCell", for: indexPath) as! TeamCollectionViewCell
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell", for: indexPath) as! TeamCollectionViewCell
            cell.members = self.members?[indexPath.row]
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectCell", for: indexPath) as! TeamCollectionViewCell
            cell.projects = self.projects?[indexPath.row]
            //cell.backgroundImage.backgroundColor = RandomFlatColorWithShade(.Dark)
            cell.backgroundImage.backgroundColor = self.colors[indexPath.row % self.colors.count]
            cell.backgroundImage.layer.cornerRadius = 10
            cell.backgroundImage.layer.borderWidth = 2
            cell.backgroundImage.layer.borderColor = UIColor.white.cgColor
            cell.backgroundImage.clipsToBounds = true
            cell.projectIcon.backgroundColor = UIColor.clear
            cell.projectIcon.layer.cornerRadius = 15
            cell.projectIcon.clipsToBounds = true
            cell.projectIcon.layer.borderWidth = 2
            cell.projectIcon.layer.borderColor = UIColor.white.cgColor
            return cell
        }
    }
    
    func segmentedControlDidChangeSegmend(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.selectedIndex = 0
            self.stopActivityIndicatorView()
            self.loadUserShots()
        case 1:
            self.selectedIndex = 1
            self.stopActivityIndicatorView()
            self.loadTeamMembers()
        case 2:
            self.selectedIndex = 2
            self.stopActivityIndicatorView()
            self.loadProjects()
        default: break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! HeaderView
        headerView.segmentedControl?.addTarget(self, action: #selector(segmentedControlDidChangeSegmend(_:)), for: .valueChanged)
        headerView.locationLabel.text = location
        headerView.avatarImageURL = avatarImageURL
        headerView.userID = userID
        //headerView.avatarImage.hnk_setImageFromURL(avatarImageURL)
        headerView.avatarImage.sd_setImage(with: avatarImageURL, placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
        
        //Add Border & border color
        headerView.avatarImage.layer.borderWidth = 2.0
        headerView.avatarImage.layer.borderColor = UIColor.white.cgColor
        //headerView.avatarImage.clipsToBounds = true
        
        /*
        //add shadow
        headerView.shadowView.backgroundColor = UIColor.clearColor()
        headerView.shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        //shadowView.layer.shadowOffset = CGSizeMake(-2, 2); //Left-Bottom shadow
        headerView.shadowView.layer.shadowOffset = CGSizeMake(-10, 10); //Right-Bottom shadow
        headerView.shadowView.layer.shadowOpacity = 1.0
        headerView.shadowView.layer.shadowRadius = 2
        */
        //Add Rounded Corners to avatarImage
        headerView.avatarImage.layer.cornerRadius = 30
        headerView.avatarImage.layer.masksToBounds = true
        
        
        /*headerView.avatarImage.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.avatarImage.layer.shadowOpacity = 0.4
        headerView.avatarImage.layer.shadowOffset =
            CGSize(width: 0, height: 2)
        headerView.avatarImage.layer.shadowRadius = 2*/
        
        
        headerView.checkIfFollowing(userID)
        
        headerView.segmentedControl.selectedSegmentIndex = selectedIndex
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, forKey: NSFontAttributeName as NSCopying)
        headerView.segmentedControl.setTitleTextAttributes(attr as! [AnyHashable: Any] , for: UIControlState())
        headerView.segmentedControl.layer.borderColor = UIColor.white.cgColor
        headerView.segmentedControl.layer.cornerRadius = 14.5
        headerView.segmentedControl.clipsToBounds = true
        headerView.segmentedControl.layer.borderWidth = 2
        headerView.segmentedControl.tintColor = UIColor.white
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if selectedIndex == 0 {
            return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.width/3)
        }else if selectedIndex == 1{
            return CGSize(width: collectionView.frame.width/6, height: 55)
        }else{
            return CGSize(width: collectionView.frame.width, height: 70)
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
            performSegue(withIdentifier: "ShotDetailSegue", sender: indexPath)
        case 1:
            performSegue(withIdentifier: "ShowUserSegue", sender: indexPath)
        case 2:
            performSegue(withIdentifier: "ProjectShotsSegue", sender: indexPath)
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
        /*if segue.identifier == "showMoreSegue"{
            let toView = segue.destinationViewController as! MoreCollectionViewController
            guard let teamID = self.user?["id"]!.int else {return}
            toView.teamID = teamID
        }*/
        if segue.identifier == "ShowUserSegue"{
            let indexPath = sender as! IndexPath
            let toView = segue.destination as! UserCollectionViewController
            toView.userID = self.members?[indexPath.row]["id"].int

        }
        if segue.identifier == "ProjectShotsSegue"{
            let indexPath = sender as! IndexPath
            let toView = segue.destination as! ProjectShotsCollectionViewController
            toView.projectID = self.projects?[indexPath.row]["id"].int
            toView.projectTitle = self.projects?[indexPath.row]["name"].string
            toView.isBucket = false
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}
