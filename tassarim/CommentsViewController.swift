//
//  CommentsViewController.swift
//  tassarim
//
//  Created by saylanc on 10/01/17.
//  Copyright © 2017 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var comments: [JSON]? = []
    var shotID: Int!
    var activityIndicatorView : NVActivityIndicatorView!
    var userType: String! = ""
    @IBOutlet weak var addCommentView: UIView!
    @IBOutlet weak var textFieldBottom: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBAction func sendButtonDidTouch(sender: AnyObject) {
    }
    private func addActivityIndicator() {
        let frame = CGRect(x: tableView!.center.x - 40 / 2, y: tableView!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.LineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.blackColor())
        
        if let activityIndicatorView = activityIndicatorView {
            view.addSubview(activityIndicatorView)
            self.tableView!.separatorStyle = .None
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
                    indicator.removeFromSuperview()
                    self.tableView!.separatorStyle = .SingleLine
            })
        }
    }

    @IBAction func designerButtonDidTouch(sender: AnyObject) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        if self.userType == "Team" {
            performSegueWithIdentifier("TeamSegue", sender: indexPath)
        }else if self.userType == "Player" {
            performSegueWithIdentifier("UserSegue", sender: indexPath)
        }
    }

    
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GAnalytics.sharedInstance.sendScreenTracking("CommentsView, ID:\(shotID)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadComments()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        /*let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentsViewController.DismissKeyboard))
        self.tableView.addGestureRecognizer(tap)*/
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentsViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentsViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func DismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    func keyboardWillShow(sender: NSNotification) {
       /* //self.view.frame.origin.y = -150
        let info  = sender.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        print("keyboardFrame: \(keyboardFrame)")
        
        UIView.animateWithDuration(0.3,
                                   delay: 0.1,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 1,
                                   options: .CurveLinear,
                                   animations: { _ in
                                    self.textFieldBottom.constant = keyboardFrame.height

            },
                                   completion: { _ in
            }
        )*/
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.textFieldBottom?.constant += keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        //self.view.frame.origin.y = 0
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.textFieldBottom?.constant = 0
        }    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentsTableViewCell
        let type = self.comments?[indexPath.row]["user"]["type"]
        self.userType = type?.string
        cell.comments = self.comments?[indexPath.row]
        cell.designerButton.tag = indexPath.row
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
