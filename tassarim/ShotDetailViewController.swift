//
//  ShotDetailViewController.swift
//  tassarim
//
//  Created by saylanc on 30/10/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import Gifu
import SafariServices
import MXParallaxHeader

class ShotDetailViewController: UIViewController, SFSafariViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var attachmentCollection: UIView!
    @IBOutlet weak var attachedImage1: UIImageView!
    @IBOutlet weak var attachedImage2: UIImageView!
    @IBOutlet weak var attachedImage3: UIImageView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var isProView: UIView!
    @IBOutlet weak var proLabel: UILabel!
    @IBOutlet weak var shotview: AnimatableImageView!
    @IBOutlet weak var shotImageView: UIImageView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var shotTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var flipView: UIView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var bucketButton: UIButton!
    @IBOutlet weak var bucketView: UIView!
    @IBOutlet weak var bucketTableView: UITableView!
    @IBOutlet weak var commentXLayout: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shotImageBack: UIImageView!
    @IBAction func shareButtonDidTouch(sender: AnyObject) {
        GAnalytics.sharedInstance.trackAction("BUTTON", action: "shareButton", label: "share \(self.shotID)", value: 1)
        let textToShare = "Shared with @tassarimapp"
        guard let url = self.shot?["html_url"]!.string else{return}
        if let myWebsite = NSURL(string: url) {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = sender as? UIView
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    @IBAction func bucketButtonDidTouch(sender: AnyObject) {
        if DribbbleAPI.sharedInstance.isAuthenticated() {
            self.showBucket()
        }else{
            performSegueWithIdentifier("LoginSegue", sender: self)
            /*let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = mainStoryBoard.instantiateViewControllerWithIdentifier("LoginVC")
            self.presentViewController(loginVC, animated: true, completion: nil)*/
        }
    }
    
    @IBAction func showImageButtonDidTouch(sender: AnyObject) {
        //performSegueWithIdentifier("ImageSegue", sender: nil)
        /*if isDescriptionViewVisible == false {
            //self.descriptionView.hidden = false
            UIView.transitionWithView(descriptionView, duration: 0.8, options: .TransitionCrossDissolve, animations: {() -> Void in
                self.descriptionView.hidden = false
                self.descriptionView.layer.cornerRadius = 10
                self.descriptionView.clipsToBounds = true
                self.shotview.hidden = true
                self.isDescriptionViewVisible = true
                }, completion: { _ in })
            //self.descriptionView.backgroundColor = UIColor(white: 1, alpha: 0.2)

        }else{
            UIView.transitionWithView(shotview, duration: 0.8, options: .TransitionCrossDissolve, animations: {() -> Void in
                self.descriptionView.hidden = true
                self.shotview.hidden = false
                self.isDescriptionViewVisible = false
                }, completion: { _ in })

        }*/
        if isDescriptionViewVisible == false {
            self.isDescriptionViewVisible = true
            UIView.transitionFromView(shotview, toView: descriptionView , duration: 0.65, options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
        }else{
            self.isDescriptionViewVisible = false
            UIView.transitionFromView(descriptionView, toView: shotview , duration: 0.65, options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
        }
    }
    
    @IBAction func showCommentsButtonDidTouch(sender: AnyObject) {
        performSegueWithIdentifier("ShowCommentsSegue", sender: nil)
    }
    @IBAction func userButtonDidTouch(sender: AnyObject) {
        /*if DribbbleAPI.sharedInstance.isAuthenticated() {
            performSegueWithIdentifier("UserSegue", sender: nil)
        }else{
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = mainStoryBoard.instantiateViewControllerWithIdentifier("LoginVC")
            self.presentViewController(loginVC, animated: true, completion: nil)
        }*/
        if self.userType == "Team" {
            performSegueWithIdentifier("TeamSegue", sender: nil)
        }else if self.userType == "Player" {
            performSegueWithIdentifier("UserSegue", sender: nil)
        }
        
    }
    
    @IBAction func likeButtonDidTouch(sender: AnyObject) {
        if DribbbleAPI.sharedInstance.isAuthenticated() {
            DribbbleAPI.sharedInstance.isLiked(shotID) { (liked) in
                if liked {
                    self.unlikeShot()
                }else{
                    self.likeAShot()
                }
            }
        }else{
            performSegueWithIdentifier("LoginSegue", sender: self)
            /*let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = mainStoryBoard.instantiateViewControllerWithIdentifier("LoginVC")
            self.presentViewController(loginVC, animated: true, completion: nil)*/
        }
    }
    
    
    /*override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if (presentingViewController != viewControllerToPresent) {
            super.presentViewController(viewControllerToPresent, animated: true, completion: nil)
        }
    }*/
    
    func likeAShot(){
        DribbbleAPI.sharedInstance.likeAShot(shotID) { (liked) in
            if liked {
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "likeAShot", label: "like \(self.shotID)", value: 1)
                self.likeButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
                UIView.animateWithDuration(0.3,
                        delay: 0.1,
                        usingSpringWithDamping: 0.5,
                        initialSpringVelocity: 1,
                        options: .CurveLinear,
                        animations: { _ in
                             self.likeButton.transform = CGAffineTransformIdentity
                             self.setLikeStatus(true)
                    },
                    completion: { _ in
                    }
                )
                
                /*UIView.animateWithDuration(0.6, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .CurveLinear,
                    animations: {
                        self.likeButton.transform = CGAffineTransformMakeScale(0.6, 0.6)

                        self.setLikeStatus(true)
                    },
                    completion: { finish in
                    
                        UIView.animateWithDuration(0.6){
                            self.likeButton.transform = CGAffineTransformIdentity
                        }
                    }
                )*/
            }
        }
    }
    
    func unlikeShot(){
        DribbbleAPI.sharedInstance.unlikeAShot(shotID) { (unliked) in
            if unliked {
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "unlikeAShot", label: "unlike \(self.shotID)", value: 1)
                self.likeButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
                UIView.animateWithDuration(0.3,
                                           delay: 0.1,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 1,
                                           options: .CurveLinear,
                                           animations: { _ in
                                            self.likeButton.transform = CGAffineTransformIdentity
                                            self.setLikeStatus(false)
                    },
                                           completion: { _ in
                    }
                )
            }
        }
    }
    
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    var att1URL: String = ""
    var att2URL: String = ""
    var att3URL: String = ""
    var button1Tapped: Bool = false
    var button2Tapped: Bool = false
    var button3Tapped: Bool = false
    @IBAction func button1DidTouch(sender: AnyObject) {
        if att1URL != "" {
            let targetURL = NSURL(string: att1URL)
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(URL: targetURL!, entersReaderIfAvailable: true)
                vc.delegate = self
                presentViewController(vc, animated: true, completion: nil)
            } else {
                performSegueWithIdentifier("WebSegue", sender: self)
                self.button1Tapped = true
            }
        }
    }
    @IBAction func button2DidTouch(sender: AnyObject) {
        if att2URL != "" {
            let targetURL = NSURL(string: att2URL)
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(URL: targetURL!, entersReaderIfAvailable: true)
                vc.delegate = self
                presentViewController(vc, animated: true, completion: nil)
            } else {
                performSegueWithIdentifier("WebSegue", sender: self)
                self.button2Tapped = true
            }
        }
    }
    @IBAction func button3DidTouch(sender: AnyObject) {
        if att3URL != "" {
            let targetURL = NSURL(string: att3URL)
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(URL: targetURL!, entersReaderIfAvailable: true)
                vc.delegate = self
                presentViewController(vc, animated: true, completion: nil)
            } else {
                performSegueWithIdentifier("WebSegue", sender: self)
                self.button3Tapped = true
            }
        }
    }
    
    var isDescriptionViewVisible: Bool = false
    var animationOptionsRight = [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews]
    var animationOptionsLeft = [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews]

    var shotID: Int!
    var shot: [String:JSON]? = [:]
    var shots_url: String!
    var userShots: [JSON]? = []
    var attachments: [JSON]? = []
    var isLike: [String:JSON]? = [:]
    var openUrl: String! = ""
    var userType: String! = ""
    
    var activityIndicatorView : NVActivityIndicatorView!
    var myView : UIView!
    
    private func addActivityIndicator() {
        let frame = CGRect(x: view!.center.x - 40 / 2, y: view!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.LineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.blackColor())
        
        myView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        self.view.addSubview(myView)
        myView.backgroundColor = UIColor(rgba: "#E0E5DA")
        view.addSubview(myView)

        if let activityIndicatorView = activityIndicatorView {
            myView.addSubview(activityIndicatorView)
        }
        
    }
    
    
    func setLikeStatus(status: Bool) {
        if status == true {
            self.likeButton.layer.cornerRadius = self.likeButton.frame.size.height/2
            self.likeButton.layer.backgroundColor = UIColorFromRGB(0xF45081).CGColor
            self.likeButton.layer.borderColor = UIColor.clearColor().CGColor
            self.likeButton.layer.shadowColor = UIColorFromRGB(0xF45081).CGColor
            self.likeButton.layer.shadowOpacity = 0.5
            self.likeButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.likeButton.layer.shadowRadius = 5
            self.likeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.likeButton.setTitle("Like", forState: UIControlState.Normal)
        }else{
            self.likeButton.layer.cornerRadius = self.likeButton.frame.size.height/2
            self.likeButton.layer.backgroundColor = UIColor.clearColor().CGColor
            self.likeButton.layer.borderWidth = 1.0
            self.likeButton.layer.borderColor = UIColorFromRGB(0xAAAAAA).CGColor
            self.likeButton.layer.shadowColor = UIColorFromRGB(0xAAAAAA).CGColor
            self.likeButton.layer.shadowOpacity = 0.5
            self.likeButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.likeButton.layer.shadowRadius = 5
            self.likeButton.setTitleColor(UIColorFromRGB(0xAAAAAA), forState: UIControlState.Normal)
            self.likeButton.setTitle("Like?", forState: UIControlState.Normal)
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
    func openBrowser() {
        let targetURL = NSURL(string: self.openUrl)
        if #available(iOS 9.0, *) {
            let vc = SFSafariViewController(URL: targetURL!, entersReaderIfAvailable: true)
            vc.delegate = self
            
            presentViewController(vc, animated: true, completion: nil)
            
        } else {
            performSegueWithIdentifier("WebSegue", sender: self)
        }
    }
    
    func openComments() {
        performSegueWithIdentifier("ShowCommentsSegue", sender: nil)
    }
    
    func createButtons() {
        if DribbbleAPI.sharedInstance.isAuthenticated() {
            DribbbleAPI.sharedInstance.isLiked(shotID) { (liked) in
                if liked {
                    self.setLikeStatus(true)
                }else{
                    self.setLikeStatus(false)
                }
            }
        }else {
            self.likeButton.layer.cornerRadius = self.likeButton.frame.size.height/2
            self.likeButton.layer.backgroundColor = UIColor.clearColor().CGColor
            self.likeButton.layer.borderWidth = 1.0
            self.likeButton.layer.borderColor = UIColorFromRGB(0xAAAAAA).CGColor
            self.likeButton.layer.shadowColor = UIColorFromRGB(0xAAAAAA).CGColor
            self.likeButton.layer.shadowOpacity = 0.5
            self.likeButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.likeButton.layer.shadowRadius = 5
            self.likeButton.setTitleColor(UIColorFromRGB(0xAAAAAA), forState: UIControlState.Normal)
            self.likeButton.setTitle("Like?", forState: UIControlState.Normal)
            
            /*self.likeButton.hidden = true
            self.shareButton.hidden = true
            self.bucketButton.hidden = true
            let horizonalContraints = NSLayoutConstraint(item: commentsButton, attribute:
                .LeadingMargin, relatedBy: .Equal, toItem: view,
                                attribute: .LeadingMargin, multiplier: 1.0,
                                constant: 8)
            NSLayoutConstraint.activateConstraints([horizonalContraints])*/
        }
        
        self.shareButton.layer.cornerRadius = self.shareButton.frame.size.height/2
        self.shareButton.layer.shadowColor = UIColorFromRGB(0xF18B68).CGColor
        self.shareButton.layer.shadowOpacity = 0.5
        self.shareButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.shareButton.layer.shadowRadius = 5
        
        self.bucketButton.layer.cornerRadius = self.bucketButton.frame.size.height/2
        self.bucketButton.layer.shadowColor = UIColorFromRGB(0x35B486).CGColor
        self.bucketButton.layer.shadowOpacity = 0.5
        self.bucketButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.bucketButton.layer.shadowRadius = 5
        
        self.commentsButton.layer.cornerRadius = self.commentsButton.frame.size.height/2
        //self.commentsButton.clipsToBounds = true
        self.commentsButton.layer.shadowColor = UIColorFromRGB(0x398EE6).CGColor
        self.commentsButton.layer.shadowOpacity = 0.5
        self.commentsButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.commentsButton.layer.shadowRadius = 5
        
        let button = UIButton()
        button.frame = CGRectMake(0, 0, 20, 20)
        button.setImage(UIImage(named: "net-internet"), forState: .Normal)
        //let url =
        button.addTarget(self, action: #selector(ShotDetailViewController.openBrowser), forControlEvents: UIControlEvents.TouchUpInside)
        let barButton = UIBarButtonItem()
        barButton.customView = button
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bucketView.hidden = true
        self.bucketTableView.delegate = self
        self.bucketTableView.dataSource = self
        
        //super.viewDidLayoutSubviews()
        //scrollView.contentSize = CGSize(width:10, height:10)
        
        /*let leftButton = UIButton()
        leftButton.frame = CGRectMake(0, 0, 20, 20)
        leftButton.setImage(UIImage(named: "cha-rounded"), forState: .Normal)
        leftButton.addTarget(self, action: #selector(ShotDetailViewController.openComments), forControlEvents: UIControlEvents.TouchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftButton
        self.navigationItem.leftBarButtonItem = leftBarButton
         */
        
        self.createButtons()
        
        self.descriptionView.layer.cornerRadius = 10
        self.descriptionView.clipsToBounds = true
        
        //self.descriptionView.hidden = true
        
        self.profileView.layer.cornerRadius = 5.0
        //self.profileView.clipsToBounds = true
        self.profileView.layer.shadowColor = UIColor.blackColor().CGColor
        self.profileView.layer.shadowOpacity = 0.2
        self.profileView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.profileView.layer.shadowRadius = 2
        
        self.startActivityIndicatorView()
        
        DribbbleAPI.sharedInstance.loadAttachments(shotID) { (attachment) in
            if let data = attachment.arrayValue as [JSON]?{
                self.attachments = data
                if  self.attachments!.count > 0 {
                    
                    self.attachmentCollection.layer.cornerRadius = 5
                    //self.attachmentCollection.clipsToBounds = true
                    self.attachmentCollection.layer.shadowColor = UIColor.blackColor().CGColor
                    self.attachmentCollection.layer.shadowOpacity = 0.2
                    self.attachmentCollection.layer.shadowOffset = CGSize(width: 0, height: 2)
                    self.attachmentCollection.layer.shadowRadius = 2
                    
                    guard let urlString1 = self.attachments?[0]["thumbnail_url"] else{return}
                    guard let url = self.attachments?[0]["url"].string else{return}
                    self.att1URL = url

                    let url1 = NSURL(string: urlString1.stringValue)
                    self.attachedImage1.sd_setImageWithURL(url1!)
                    self.attachedImage1.layer.cornerRadius = 5
                    self.attachedImage1.clipsToBounds = true
                    self.attachedImage1.layer.shadowColor = UIColorFromRGB(0xAAAAAA).CGColor
                    self.attachedImage1.layer.shadowOpacity = 0.5
                    self.attachedImage1.layer.shadowOffset = CGSize(width: 0, height: 2)
                    self.attachedImage1.layer.shadowRadius = 2

                    self.button1.hidden = false
                    self.button2.hidden = true
                    self.button3.hidden = true
                    
                    if self.attachments!.count > 1{
                        guard let urlString2 = self.attachments?[1]["thumbnail_url"] else{return}
                        guard let url = self.attachments?[1]["url"].string else{return}
                        self.att2URL = url
                        let url2 = NSURL(string: urlString2.stringValue)
                        self.attachedImage2.sd_setImageWithURL(url2!)
                        self.attachedImage2.layer.cornerRadius = 5
                        self.attachedImage2.clipsToBounds = true
                        self.attachedImage2.layer.shadowColor = UIColorFromRGB(0xAAAAAA).CGColor
                        self.attachedImage2.layer.shadowOpacity = 0.5
                        self.attachedImage2.layer.shadowOffset = CGSize(width: 0, height: 2)
                        self.attachedImage2.layer.shadowRadius = 2
                        self.button3.hidden = true
                    }
                    if self.attachments!.count == 3 {
                        guard let urlString3 = self.attachments?[2]["thumbnail_url"].stringValue else{return}
                        guard let url = self.attachments?[2]["url"].string else{return}
                        self.att3URL = url
                        let url3 = NSURL(string: urlString3)
                        self.attachedImage3.sd_setImageWithURL(url3!)
                        self.attachedImage3.layer.cornerRadius = 5
                        self.attachedImage3.clipsToBounds = true
                        self.attachedImage3.layer.shadowColor = UIColorFromRGB(0xAAAAAA).CGColor
                        self.attachedImage3.layer.shadowOpacity = 0.5
                        self.attachedImage3.layer.shadowOffset = CGSize(width: 0, height: 2)
                        self.attachedImage3.layer.shadowRadius = 2
                    }
                }else{
                    self.attachmentCollection.hidden = true
                }
            }
        }
        
        DribbbleAPI.sharedInstance.loadShot(shotID) { (shot) in
            if let data = shot.dictionaryValue as [String:JSON]?{
                self.shot = data
                print(data)
                self.openUrl = self.shot?["html_url"]?.stringValue

                if let isAnimated = self.shot?["animated"]?.bool {
                    if !isAnimated {
                        if let urlString = self.shot?["images"]!["normal"].string where urlString.characters.count > 0{
                            let url = NSURL(string: urlString)
                            if let data = NSData(contentsOfURL: url!) {
                                self.shotview.animateWithImageData(data)
                                self.shotview.layer.cornerRadius = 10
                                self.shotview.clipsToBounds = true
                                //Setup the back shot Image with blur effect
                                self.shotImageBack.sd_setImageWithURL(url!)
                                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                blurEffectView.frame = self.shotImageBack.bounds
                                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                self.shotImageBack.addSubview(blurEffectView)
                            }
                        }
                    }else{
                        if let urlString = self.shot?["images"]!["hidpi"].string where urlString.characters.count > 0{
                            let url = NSURL(string: urlString)
                            if let data = NSData(contentsOfURL: url!) {
                                self.shotview.animateWithImageData(data)
                                self.shotview.layer.cornerRadius = 10
                                self.shotview.clipsToBounds = true
                                //Setup the back shot Image with blur effect
                                self.shotImageBack.sd_setImageWithURL(url!)
                                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                blurEffectView.frame = self.shotImageBack.bounds
                                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                self.shotImageBack.addSubview(blurEffectView)
                            }
                        }else if let urlString = self.shot?["images"]!["normal"].string where urlString.characters.count > 0{
                            let url = NSURL(string: urlString)
                            if let data = NSData(contentsOfURL: url!) {
                                self.shotview.animateWithImageData(data)
                                self.shotview.layer.cornerRadius = 10
                                self.shotview.clipsToBounds = true
                                //Setup the back shot Image with blur effect
                                self.shotImageBack.sd_setImageWithURL(url!)
                                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                blurEffectView.frame = self.shotImageBack.bounds
                                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                self.shotImageBack.addSubview(blurEffectView)
                            }
                        }
                    }
                }
                
                /*if let urlString = self.shot?["images"]!["hidpi"].string where urlString.characters.count > 0{
                    print("11: \(urlString)")
                    let url = NSURL(string: urlString)
                    if let data = NSData(contentsOfURL: url!) {
                        self.shotview.animateWithImageData(data)
                        self.shotview.layer.cornerRadius = 10
                        self.shotview.clipsToBounds = true}
                }else if let urlString = self.shot?["images"]!["normal"].string where urlString.characters.count > 0{
                    let url = NSURL(string: urlString)
                    if let data = NSData(contentsOfURL: url!) {
                        self.shotview.animateWithImageData(data)
                        self.shotview.layer.cornerRadius = 10
                        self.shotview.clipsToBounds = true}
                }else if let urlString = self.shot?["images"]!["teaser"].string where urlString.characters.count > 0{
                    let url = NSURL(string: urlString)
                    if let data = NSData(contentsOfURL: url!) {
                        self.shotview.animateWithImageData(data)
                        self.shotview.layer.cornerRadius = 10
                        self.shotview.clipsToBounds = true}
                }*/
            
                if let urlAvatar = self.shot?["user"]!["avatar_url"]{
                    let url = NSURL(string: urlAvatar.stringValue)
                    self.userAvatar.sd_setImageWithURL(url!)
                    self.userAvatar.layer.cornerRadius = self.userAvatar.frame.size.width/2
                    //self.userAvatar.layer.borderWidth = 2
                    //self.userAvatar.layer.borderColor = UIColor(rgba: "#46454B").CGColor
                    self.userAvatar.clipsToBounds = true
                }
                
                let likeInt: Int = (self.shot?["likes_count"]?.int)!
                let likeString: String = String(likeInt)
                self.likesCountLabel.text = likeString
                
                let viewInt: Int = (self.shot?["views_count"]?.int)!
                let viewString: String = String(viewInt)
                self.viewsCountLabel.text = viewString
            
                self.shotTitleLabel.text = self.shot?["title"]?.string
                self.userNameLabel.text = self.shot?["user"]!["name"].string
                self.title = self.shot?["user"]!["name"].string
                if let description_text = self.shot?["description"]?.string {
                    let attrStr = try! NSAttributedString(
                        data: description_text.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                        options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                        documentAttributes: nil)
                        self.descriptionLabel.attributedText = attrStr
                        self.descriptionLabel.font = UIFont(name: "System", size: 14)
                }else{
                    self.descriptionLabel.text = ""
                }

                self.shots_url = self.shot?["user"]!["shots_url"].string
                //self.loadUserShots()
                
                let type = self.shot?["user"]!["type"]
                self.userType = type?.string
                if type == "Player" {
                    if let isPro = self.shot?["user"]!["pro"]{
                        if isPro{
                            self.proLabel.text = "Pro"
                            self.isProView.layer.cornerRadius = 6
                            self.isProView.clipsToBounds = true
                        }else{
                            self.isProView.hidden = true
                        }
                    }
                }else if type == "Team" {
                    self.proLabel.text = "Team"
                    self.isProView.layer.cornerRadius = 6
                    self.isProView.clipsToBounds = true
                }
                
                self.stopActivityIndicatorView()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        scrollView.scrollEnabled = true
        // Do any additional setup after loading the view
        scrollView.contentSize = CGSizeMake(320, 500)
    }
    
    /*func loadUserShots(){
        DribbbleAPI.sharedInstance.loadUserShots(shots_url) { (userShots) in
            if let data = userShots.arrayValue as [JSON]? {
                self.userShots = data
            }
        }
        
    }*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ImageSegue"{
            let toView = segue.destinationViewController as! ImageViewController
            if let shotURL = self.shot?["images"]!["normal"]{
                let url = NSURL(string: shotURL.stringValue)
                toView.shotURL = url
            }
        }
        
        if segue.identifier == "UserSegue"{
            let toView = segue.destinationViewController as! UserCollectionViewController
            let userID = self.shot?["user"]!["id"].int
            self.navigationController?.title = self.shot?["user"]!["name"].string
            self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#798BF8")
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            toView.userID = userID
        }
        
        if segue.identifier == "TeamSegue"{
            let toView = segue.destinationViewController as! TeamCollectionViewController
            let userID = self.shot?["user"]!["id"].int
            self.navigationController?.title = self.shot?["user"]!["name"].string
            self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#FFC27E")
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            toView.userID = userID
        }
        
        /*if segue.identifier == "WebSegue" {
            let toView = segue.destinationViewController as! WebViewController
            if button1Tapped{
                toView.url = self.att1URL
            }else if button2Tapped{
                toView.url = self.att2URL
            }else if button3Tapped{
                toView.url = self.att3URL
            }else{
                toView.url = self.openUrl
            }
        }*/
        if segue.identifier == "ShowCommentsSegue" {
            let toView = segue.destinationViewController as! CommentsTableViewController
            toView.shotID = shotID
            toView.title = self.shotTitleLabel.text
            GAnalytics.sharedInstance.trackAction("BUTTON", action: "showComment", label: "comment \(self.shotID)", value: 1)
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    
    //Buckets
    var buckets: [JSON]? = []
    let blackView = UIView()

    func showBucket(){
        self.bucketTableView.separatorStyle = .None
        self.loadBucketList()
        if let window = UIApplication.sharedApplication().keyWindow {
            blackView.backgroundColor = UIColor(white: 0 , alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            //only top lef&right cornerse have corner radius
            /*let maskPath = UIBezierPath(roundedRect: bucketTableView.bounds,
                                        byRoundingCorners: [.TopLeft, .TopRight],
                                        cornerRadii: CGSize(width: 10.0, height: 10.0))
            let shape = CAShapeLayer()
            shape.path = maskPath.CGPath
            bucketTableView.layer.mask = shape*/
            //bucketTableView.layer.roundCorners([.TopLeft, .TopRight], radius: 10)

            window.addSubview(blackView)
            window.addSubview(bucketTableView)
            
            let height: CGFloat = 250
            let y = window.frame.height - height
            bucketTableView.frame = CGRectMake(0, window.frame.height, window.frame.width, 250)
            blackView.frame = window.frame
            blackView.alpha = 0
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
                self.blackView.alpha = 1
                self.bucketTableView.frame = CGRectMake(0, y, self.bucketTableView.frame.width, self.bucketTableView.frame.height)
                }, completion: nil)
        }
    }
    
    func handleDismiss() {
        UIView.animateWithDuration(0.5, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.sharedApplication().keyWindow {
                self.bucketTableView.frame = CGRectMake(0, window.frame.height, self.bucketTableView.frame.width, self.bucketTableView.frame.height)
            }
        })
    }
    
    var bucketID: Int!
    func loadBucketList(){
        DribbbleAPI.sharedInstance.listUsersBuckets{(buckets) in
             if let data = buckets.arrayValue as [JSON]? {
             self.buckets = data
                print(data)
             GAnalytics.sharedInstance.trackAction("BUTTON", action: "showBucket", label: "bucket", value: 1)
             self.bucketTableView!.reloadData()
             }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.buckets?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BucketCell", forIndexPath: indexPath) as! BucketListTableViewCell
        
        cell.bucketNameLabel.text = self.buckets?[indexPath.row]["name"].string
        cell.bucketImage.image = UIImage(named: "bucket")
        if let sInt = self.buckets?[indexPath.row]["shots_count"].int {
            let sString = String(sInt)
            cell.shotsCountLabel.text = sString
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        bucketID = self.buckets?[indexPath.row]["id"].int
        self.startActivityIndicatorView()
        DribbbleAPI.sharedInstance.updateBucket(bucketID, shotID: shotID) { (response) in
            if response == true {
                self.stopActivityIndicatorView()
                self.handleDismiss()
            }else {
                print("bucket başarısız")
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor(rgba: "#F45081")
        GAnalytics.sharedInstance.sendScreenTracking("ShotDetailView, ID:\(shotID)")
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        self.scrollView.scrollEnabled = true

        // Add extra 15pt on the `top` of scrollView.
        //self.scrollView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
        
        // Add extra 2pt on the `bottom` of scrollView, let it be scrollable. And the UI is more beautiful in my case.
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 2, 0)
    }
}
