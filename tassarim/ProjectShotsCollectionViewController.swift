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

    fileprivate func addActivityIndicator() {
        let frame = CGRect(x: collectionView!.center.x - 40 / 2, y: collectionView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.lineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.white)
        
        myView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView!.frame.width, height: collectionView!.frame.height))
        self.view.addSubview(myView)
        myView.backgroundColor = UIColor("#F45081")
        view.addSubview(myView)
        if let activityIndicatorView = activityIndicatorView {
            myView.addSubview(activityIndicatorView)
        }
    }
    
    func startActivityIndicatorView() {
        addActivityIndicator()
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
    }

    func loadProjectShots() {
        startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadShotsofProject(projectID) { (shots) in
            if let data = shots.arrayValue as [JSON]?{
                self.shots?.append(contentsOf: data)
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    func loadBucketShots(){
        startActivityIndicatorView()
        DribbbleAPI.sharedInstance.listShotsofBucket(bucketID) { (shots) in
            if let data = shots.arrayValue as [JSON]?{
                self.shots?.append(contentsOf: data)
                self.collectionView?.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //remove hairline under the navbar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor("#F45081")
        self.navigationController?.navigationBar.isTranslucent = false
        GAnalytics.sharedInstance.sendScreenTracking("ProjectShotsView")
    }
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shots?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectShotCell", for: indexPath) as! ProjectShotsCollectionViewCell
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
    }
}
