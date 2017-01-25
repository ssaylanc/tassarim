//
//  ProjectShotsCollectionViewController.swift
//  tassarim
//
//  Created by saylanc on 09/01/17.
//  Copyright © 2017 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class ProjectShotsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {

    var shots: [JSON]? = []
    var activityIndicatorView : NVActivityIndicatorView!
    var projectID: Int!
    var bucketID: Int!
    var isBucket: Bool!
    var projectTitle: String!
    var bucketTitle: String!
    var myView : UIView!

    private func addActivityIndicator() {
        let frame = CGRect(x: collectionView!.center.x - 40 / 2, y: collectionView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.LineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.whiteColor())
        
        myView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView!.frame.width, height: collectionView!.frame.height))
        self.view.addSubview(myView)
        myView.backgroundColor = UIColor(rgba: "#F45081")
        view.addSubview(myView)
        if let activityIndicatorView = activityIndicatorView {
            myView.addSubview(activityIndicatorView)
        }
    }
    
    func startActivityIndicatorView() {
        addActivityIndicator()
        if let indicator = activityIndicatorView {
            indicator.startAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
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
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.myView.removeFromSuperview()
                    indicator.removeFromSuperview()
            })
        }
    }

    func loadProjectShots() {
        startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadShotsofProject(projectID) { (shots) in
            if let data = shots.arrayValue as [JSON]?{
                self.shots?.appendContentsOf(data)
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    func loadBucketShots(){
        startActivityIndicatorView()
        DribbbleAPI.sharedInstance.listShotsofBucket(bucketID) { (shots) in
            if let data = shots.arrayValue as [JSON]?{
                self.shots?.appendContentsOf(data)
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //remove hairline under the navbar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        if isBucket == false{
            self.title = projectTitle
            self.loadProjectShots()
        }else {
            self.title = bucketTitle
            self.loadBucketShots()
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor(rgba: "#F45081")
        self.navigationController?.navigationBar.translucent = false
        GAnalytics.sharedInstance.sendScreenTracking("ProjectShotsView")
    }
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shots?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProjectShotCell", forIndexPath: indexPath) as! ProjectShotsCollectionViewCell
        cell.shot = self.shots?[indexPath.row]
        
        /*if (indexPath.row == self.shots!.count - 6) {
         page += 1
         self.startActivityIndicatorView()
         loadShots(list_name, page: page)
         }*/
        /*let rowsToLoadFromBottom = 3;
        let rowsLoaded = self.shots!.count
        if (!self.isShotsLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)))
        {
            page += 1
            self.startActivityIndicatorView()
            loadShots(list_name, page: page)
        }*/
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShotDetailSegue", sender: indexPath)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        GAnalytics.sharedInstance.trackAction("CELL", action: "CELL SELECT", label: "\(self.shots?[indexPath.row]["id"].int)", value: 1)
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