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
    @IBAction func segmentedControlAction(_ sender: AnyObject) {
        
    }

    //var user: [String:JSON]? = [:]
    
    var userID: Int!
    var avatarImageURL: URL!
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
            self.followButton.isHidden = true
        }
        
    }
    
    @IBAction func followButtonDidTouch(_ sender: AnyObject) {
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
    
    func checkIfFollowing(_ userID: Int){
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
                self.followButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                UIView.animate(withDuration: 0.3,
                                           delay: 0.1,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 1,
                                           options: .curveLinear,
                                           animations: { _ in
                                            self.followButton.transform = CGAffineTransform.identity
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
                self.followButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                UIView.animate(withDuration: 0.3,
                                           delay: 0.1,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 1,
                                           options: .curveLinear,
                                           animations: { _ in
                                            self.followButton.transform = CGAffineTransform.identity
                                            self.setFollowingButton(false)
                    },completion: { _ in}
                )
            }else{
            }
        }
    }
    
    func setFollowingButton(_ followed: Bool){
        if followed == true {
            self.followButton.layer.cornerRadius = self.followButton.frame.size.height/2
            self.followButton.layer.backgroundColor = UIColorFromRGB(0xF45081).cgColor
            self.followButton.layer.borderColor = UIColor.clear.cgColor
            self.followButton.layer.shadowColor = UIColorFromRGB(0xF45081).cgColor
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.followButton.layer.shadowRadius = 5
            self.followButton.setTitleColor(UIColor.white, for: UIControlState())
            self.followButton.setTitle("Following", for: UIControlState())
        }else{
            self.followButton.layer.cornerRadius = self.followButton.frame.size.height/2
            self.followButton.layer.backgroundColor = UIColor.clear.cgColor
            self.followButton.layer.borderWidth = 1.0
            self.followButton.layer.borderColor = UIColorFromRGB(0xAFFFFFF).cgColor
            self.followButton.layer.shadowColor = UIColorFromRGB(0xFFFFFF).cgColor
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.followButton.layer.shadowRadius = 5
            self.followButton.setTitleColor(UIColorFromRGB(0xFFFFFF), for: UIControlState())
            self.followButton.setTitle("Follow", for: UIControlState())
        }
    }
}
extension HeaderView {
    
    func setAvatar(_ url: URL){
        self.avatarImage.hnk_setImage(from: url)
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
