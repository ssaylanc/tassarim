//
//  CommentsTableViewController.swift
//  tassarim
//
//  Created by saylanc on 05/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class CommentsTableViewController: UITableViewController {

    var comments: [JSON]? = []
    var shotID: Int!
    var activityIndicatorView : NVActivityIndicatorView!
    var userID: Int!
    var userName: String!

    func loadComments(){
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.loadComments(shotID) { (comments) in
            if let data = comments.arrayValue as [JSON]? {
                self.comments = data
                self.tableView!.reloadData()
                self.stopActivityIndicatorView()
            }
        }
    }
    
    fileprivate func addActivityIndicator() {
        let frame = CGRect(x: tableView!.center.x - 40 / 2, y: tableView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.lineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.black)
        
        if let activityIndicatorView = activityIndicatorView {
            view.addSubview(activityIndicatorView)
            self.tableView!.separatorStyle = .none
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
                    self.tableView!.separatorStyle = .singleLine
            })
        }
    }
    
    var userType: String! = ""
    @IBAction func designerButtonDidTouch(_ sender: AnyObject) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if self.userType == "Team" {
            performSegue(withIdentifier: "TeamSegue", sender: indexPath)
        }else if self.userType == "Player" {
            performSegue(withIdentifier: "UserSegue", sender: indexPath)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadComments()
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 69
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GAnalytics.sharedInstance.sendScreenTracking("CommentsView, ID:\(shotID)")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments?.count ?? 0
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentsTableViewCell
        let type = self.comments?[indexPath.row]["user"]["type"]
        self.userID = self.comments?[indexPath.row]["user"]["id"].int
        self.userName = self.comments?[indexPath.row]["user"]["name"].string
        self.userType = type?.string
        cell.comments = self.comments?[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserSegue"{
            let toView = segue.destination as! UserCollectionViewController
            let userID = self.userID
            self.navigationController?.title = self.userName
            self.navigationController?.navigationBar.barTintColor = UIColor("#798BF8")
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            toView.userID = userID
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
        
        if segue.identifier == "TeamSegue"{
            let toView = segue.destination as! TeamCollectionViewController
            let userID = self.userID
            self.navigationController?.title = self.userName
            self.navigationController?.navigationBar.barTintColor = UIColor("#FFC27E")
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            toView.userID = userID
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
   /* override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor("#DCDCE8")
        }else {
            cell.backgroundColor = UIColor("#E0E5DA")
        }
    }*/
    /*override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        footer.backgroundColor = UIColor.whiteColor()
        
        return footer
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }*/
}
