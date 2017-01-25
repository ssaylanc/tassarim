//
//  HeaderView.swift
//  tassarim
//
//  Created by saylanc on 07/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var isProLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControlAction(sender: AnyObject) {
        
    }

    //var user: [String:JSON]? = [:]
    
    var userID: Int!
    var avatarImageURL: NSURL!
    var isTeamButtonHidden: Bool!    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.checkIfFollowing(userID)
        /*self.profileView.layer.cornerRadius = 10
        self.profileView.layer.shadowColor = UIColor.blackColor().CGColor
        self.profileView.layer.shadowOpacity = 0.4
        self.profileView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.profileView.layer.shadowRadius = 2*/
        
        
        /*let rectShape = CAShapeLayer()
        rectShape.bounds = self.headerImage.frame
        rectShape.position = self.headerImage.center
        let frame = CGRectMake(0, 0, self.headerImage.frame.size.width, self.headerImage.frame.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 10, height: 10)).CGPath
        self.headerImage.layer.mask = rectShape*/
        if !DribbbleAPI.sharedInstance.isAuthenticated() {
            self.followButton.hidden = true
        }
        
    }
    
    @IBAction func followButtonDidTouch(sender: AnyObject) {
         if DribbbleAPI.sharedInstance.isAuthenticated() {
            DribbbleAPI.sharedInstance.isUserFollowed(userID) { (followed) in
                print(self.userID)
                if followed {
                    self.unFollowUser()
                }else{
                    self.followUser()
                }
            }
         }else{
            /*let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = mainStoryBoard.instantiateViewControllerWithIdentifier("LoginVC")
            //self.presentViewController(loginVC, animated: true, completion: nil)
            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(loginVC, animated: true, completion: nil)*/
         }
    }
    
    func checkIfFollowing(userID: Int){
        DribbbleAPI.sharedInstance.isUserFollowed(userID) { (followed) in
            if followed {
                self.setFollowingButton(true)
            }else{
                self.setFollowingButton(false)
            }
        }
    }
    
    func followUser(){
        DribbbleAPI.sharedInstance.followUser(userID) { (followed) in
            if followed {
                    GAnalytics.sharedInstance.trackAction("BUTTON", action: "followUser", label: "follow \(self.userID)", value: 1)
                self.followButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
                UIView.animateWithDuration(0.3,
                                           delay: 0.1,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 1,
                                           options: .CurveLinear,
                                           animations: { _ in
                                            self.followButton.transform = CGAffineTransformIdentity
                                            self.setFollowingButton(true)
                    },completion: { _ in}
                )
            }else{
                
            }
        }
    }
    
    func unFollowUser(){
        DribbbleAPI.sharedInstance.unFollowUser(userID) { (unfollowed) in
            if unfollowed {
                GAnalytics.sharedInstance.trackAction("BUTTON", action: "unFollowUser", label: "follow \(self.userID)", value: 1)
                self.followButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
                UIView.animateWithDuration(0.3,
                                           delay: 0.1,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 1,
                                           options: .CurveLinear,
                                           animations: { _ in
                                            self.followButton.transform = CGAffineTransformIdentity
                                            self.setFollowingButton(false)
                    },completion: { _ in}
                )
            }else{
            }
        }
    }
    
    func setFollowingButton(followed: Bool){
        if followed == true {
            self.followButton.layer.cornerRadius = self.followButton.frame.size.height/2
            self.followButton.layer.backgroundColor = UIColorFromRGB(0xF45081).CGColor
            self.followButton.layer.borderColor = UIColor.clearColor().CGColor
            self.followButton.layer.shadowColor = UIColorFromRGB(0xF45081).CGColor
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.followButton.layer.shadowRadius = 5
            self.followButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.followButton.setTitle("Following", forState: UIControlState.Normal)
        }else{
            self.followButton.layer.cornerRadius = self.followButton.frame.size.height/2
            self.followButton.layer.backgroundColor = UIColor.clearColor().CGColor
            self.followButton.layer.borderWidth = 1.0
            self.followButton.layer.borderColor = UIColorFromRGB(0xAFFFFFF).CGColor
            self.followButton.layer.shadowColor = UIColorFromRGB(0xFFFFFF).CGColor
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.followButton.layer.shadowRadius = 5
            self.followButton.setTitleColor(UIColorFromRGB(0xFFFFFF), forState: UIControlState.Normal)
            self.followButton.setTitle("Follow", forState: UIControlState.Normal)
        }
    }
}
extension HeaderView {
    
    func setAvatar(url: NSURL){
        self.avatarImage.hnk_setImageFromURL(url)
        self.avatarImage.layer.cornerRadius = 30
        self.avatarImage.clipsToBounds = true
    }
}

/*extension CALayer {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.CGPath
        mask = shape
    }
}*/
