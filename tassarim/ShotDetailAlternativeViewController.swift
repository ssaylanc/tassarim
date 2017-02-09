//
//  ShotDetailAlternativeViewController.swift
//  tassarim
//
//  Created by saylanc on 05/02/17.
//  Copyright © 2017 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Gifu
import NVActivityIndicatorView

class ShotDetailAlternativeViewController: UIViewController {

    @IBOutlet weak var shotImageFront: AnimatableImageView!
    @IBOutlet weak var shotImageBack: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shotTitleLabel: UILabel!
    @IBOutlet weak var shotCornerView: UIView!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!

    var shotID: Int!
    var shot: [String:JSON]? = [:]
    var openUrl: String! = ""
    var myView : UIView!
    var activityIndicatorView : NVActivityIndicatorView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func likeButtonDidTouch(sender: AnyObject) {
        self.likeButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
        UIView.animateWithDuration(0.3,
                                   delay: 0.1,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 1,
                                   options: .CurveLinear,
                                   animations: { _ in
                                    self.likeButton.transform = CGAffineTransformIdentity
                                    self.likeButton.setImage(UIImage(named: "cel-heart-selected.png"), forState: UIControlState.Normal)
            },
                                   completion: { _ in
            }
        )
    }
    
    private func addActivityIndicator() {
        let frame = CGRect(x: view!.center.x - 40 / 2, y: view!.center.y - 20, width: 40, height: 40)
        let activityType = NVActivityIndicatorType.LineScale
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: activityType, color: UIColor.whiteColor())
        
            myView = UIView(frame: CGRect(x: 0, y: 0, width: view!.frame.width, height: view!.frame.height))
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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        self.navigationController?.navigationBar.translucent = true
        self.startActivityIndicatorView()
        
        DribbbleAPI.sharedInstance.loadShot(shotID) { (shot) in
            if let data = shot.dictionaryValue as [String:JSON]?{
                self.shot = data
                self.shotTitleLabel.text = self.shot?["title"]?.string
                self.userNameLabel.text = self.shot?["user"]!["name"].string
                self.openUrl = self.shot?["html_url"]?.stringValue
                if let isAnimated = self.shot?["animated"]?.bool {
                    if !isAnimated {
                        if let urlString = self.shot?["images"]!["normal"].string where urlString.characters.count > 0{
                            let url = NSURL(string: urlString)
                            if let data = NSData(contentsOfURL: url!) {
                                //Setup the front shot Image
                                self.shotImageFront.animateWithImageData(data)
                                //Add Shadow
                                self.shotCornerView.layer.shadowColor = UIColor.blackColor().CGColor
                                self.shotCornerView.layer.shadowOpacity = 0.5
                                self.shotCornerView.layer.shadowOffset = CGSizeMake(0, 10)
                                self.shotCornerView.layer.shadowRadius = 5
                                self.shotCornerView.layer.shadowPath = UIBezierPath(roundedRect: self.shotCornerView.bounds, cornerRadius: self.shotCornerView.layer.cornerRadius).CGPath
                                self.shotCornerView.layer.shouldRasterize = true
                                self.shotCornerView.layer.rasterizationScale = UIScreen.mainScreen().scale
                                //Add Corner Radius
                                let borderView = UIView()
                                borderView.frame = self.shotCornerView.bounds
                                borderView.layer.cornerRadius = 5
                                //borderView.layer.borderColor = UIColor.black.cgColor
                                //borderView.layer.borderWidth = 1.0
                                borderView.layer.masksToBounds = true
                                self.shotCornerView.addSubview(borderView)
                                
                                self.shotImageFront.frame = borderView.bounds
                                borderView.addSubview(self.shotImageFront)
                                
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
                                //Setup the front shot Image
                                self.shotImageFront.animateWithImageData(data)
                                //Add Shadow
                                self.shotCornerView.layer.shadowColor = UIColor.blackColor().CGColor
                                self.shotCornerView.layer.shadowOpacity = 0.5
                                self.shotCornerView.layer.shadowOffset = CGSizeMake(0, 5)
                                self.shotCornerView.layer.shadowRadius = 5
                                self.shotCornerView.layer.shadowPath = UIBezierPath(roundedRect: self.shotCornerView.bounds, cornerRadius: self.shotCornerView.layer.cornerRadius).CGPath
                                self.shotCornerView.layer.shouldRasterize = true
                                self.shotCornerView.layer.rasterizationScale = UIScreen.mainScreen().scale
                                //Add Corner Radius
                                let borderView = UIView()
                                borderView.frame = self.shotCornerView.bounds
                                borderView.layer.cornerRadius = 5
                                //borderView.layer.borderColor = UIColor.black.cgColor
                                //borderView.layer.borderWidth = 1.0
                                borderView.layer.masksToBounds = true
                                self.shotCornerView.addSubview(borderView)
                                
                                self.shotImageFront.frame = borderView.bounds
                                borderView.addSubview(self.shotImageFront)
                                
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
                                //Setup the front shot Image
                                self.shotImageFront.animateWithImageData(data)
                                self.shotCornerView.layer.cornerRadius = 10
                                self.shotCornerView.clipsToBounds = true
                                self.shotCornerView.layer.shadowPath = UIBezierPath(roundedRect: self.shotCornerView.bounds, cornerRadius: self.shotCornerView.layer.cornerRadius).CGPath
                                self.shotCornerView.layer.shadowColor = UIColor.blackColor().CGColor
                                self.shotCornerView.layer.shadowOpacity = 0.9
                                self.shotCornerView.layer.shadowOffset = CGSizeMake(0, 5)
                                self.shotCornerView.layer.shadowRadius = 5
                                self.shotCornerView.layer.masksToBounds = false
                                
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
                
                self.stopActivityIndicatorView()
                
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
                
                /*if let urlAvatar = self.shot?["user"]!["avatar_url"]{
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
                }*/
                
                //self.stopActivityIndicatorView()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
