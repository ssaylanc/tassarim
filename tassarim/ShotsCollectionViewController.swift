//
//  ShotsCollectionViewController.swift
//  tassarim
//
//  Created by saylanc on 29/10/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import UIColor_Hex_Swift
import NVActivityIndicatorView
import BTNavigationDropdownMenu

private let reuseIdentifier = "ShotCell"

class ShotsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {

    var shots: [JSON]? = []
    var list_name: String = ""
    var dropDownItems = ["popular", "animated", "attachments", "debuts", "playoffs", "rebounds", "teams"]
    var page = 1
    var activityIndicatorView : NVActivityIndicatorView!
    var isShotsLoading: Bool = true
    let accessToken = "dribbble_access_token"
    var authToken: String!
    var myView : UIView!
    var firstTimeLoad: Bool! = true
    
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
        isShotsLoading = true
        if let indicator = activityIndicatorView {
            indicator.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.myView.removeFromSuperview()
                    indicator.removeFromSuperview()
            })
        }
        isShotsLoading = false
    }
    
    func loadShots(_ list_name: String, page: Int = 1) {
        self.firstTimeLoad = false
        DribbbleAPI.sharedInstance.loadShots(list_name, page: page, callback: { (shots) in
            if let data = shots.arrayValue as [JSON]?{
                self.shots?.append(contentsOf: data)
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        })
    }
    
    func openProfile(){
        if DribbbleAPI.sharedInstance.isAuthenticated(){
            performSegue(withIdentifier: "openProfileSegue", sender: self)
            GAnalytics.sharedInstance.trackAction("BUTTON", action: "openProfileSegue", label: "openProfileSegue", value: 1)
        }else{
            performSegue(withIdentifier: "SignInSegue", sender: self)
             GAnalytics.sharedInstance.trackAction("BUTTON", action: "SignInSegue", label: "SignInSegue", value: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //remove hairline under the navbar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        //if DribbbleAPI.sharedInstance.isAuthenticated(){
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            button.setImage(UIImage(named: "des-pen-pot"), for: UIControlState())
            button.addTarget(self, action: #selector(ShotsCollectionViewController.openProfile), for: UIControlEvents.touchUpInside)
            let barButton = UIBarButtonItem()
            barButton.customView = button
            self.navigationItem.rightBarButtonItem = barButton
        //}
        if DribbbleAPI.sharedInstance.isAuthenticated(){
            //Dropdown Menu
            dropDownItems = ["popular", "following", "animated", "attachments", "debuts", "playoffs", "rebounds", "teams"]
        }
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: "Shots", items: dropDownItems as [AnyObject])
        
        menuView.cellSeparatorColor = UIColorFromRGB(0xF45081)
        menuView.cellTextLabelAlignment = .center
        menuView.cellSelectionColor = UIColor.white
        
        self.navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.title = self.dropDownItems[indexPath]
            self.list_name = self.dropDownItems[indexPath]
            if self.list_name == "following" {
                self.firstTimeLoad = true
                self.startActivityIndicatorView()
                self.shots?.removeAll(keepingCapacity: false)
                DribbbleAPI.sharedInstance.loadUserFollowingShots { (followingShots) in
                    if let data = followingShots.arrayValue as [JSON]? {
                        self.shots?.append(contentsOf: data)
                        self.collectionView?.reloadData()
                        self.stopActivityIndicatorView()
                    }
                }
            }else{
                self.firstTimeLoad = true
                self.startActivityIndicatorView()
                self.shots?.removeAll(keepingCapacity: false)
                self.loadShots(self.list_name)
            }
        }
        self.startActivityIndicatorView()
        self.loadShots(list_name)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor("#F45081")
        self.navigationController?.navigationBar.isTranslucent = false
        GAnalytics.sharedInstance.sendScreenTracking("ShotsView")
    }
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.shots?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ShotsCollectionViewCell
        cell.shot = self.shots?[indexPath.row]
        
        /*if (indexPath.row == self.shots!.count - 6) {
            page += 1
            self.startActivityIndicatorView()
            loadShots(list_name, page: page)
        }*/
        let rowsToLoadFromBottom = 3;
        let rowsLoaded = self.shots!.count
        if (!self.isShotsLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)))
        {
            page += 1
            self.startActivityIndicatorView()
            loadShots(list_name, page: page)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // remove lines between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShotDetailSegue", sender: indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)
        GAnalytics.sharedInstance.trackAction("CELL", action: "CELL SELECT", label: "\(self.shots?[indexPath.row]["id"].int)", value: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShotDetailSegue"{
            let toView = segue.destination as! ShotDetailViewController
            let indexPath = sender as! IndexPath
            guard let shotID = self.shots?[indexPath.row]["id"].int! else {return}
            toView.shotID = shotID
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}
