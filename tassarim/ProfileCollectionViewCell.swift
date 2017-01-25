//
//  ProfileCollectionViewCell.swift
//  tassarim
//
//  Created by saylanc on 18/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import ChameleonFramework

class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var shotImage: UIImageView!
    @IBOutlet weak var bucketName: UILabel!
    @IBOutlet weak var shotsCountLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeViewWidth: NSLayoutConstraint!
    @IBOutlet weak var backgroundImage: UIImageView!
    var followee:SwiftyJSON.JSON?{
        didSet{
            self.setupFollowee()
        }
    }
    
    var bucket:SwiftyJSON.JSON? {
        didSet{
            self.setupBukcets()
        }
    }
    var follower:SwiftyJSON.JSON?{
        didSet{
            self.setupFollower()
        }
    }
    
    var shot:SwiftyJSON.JSON?{
        didSet{
            self.setupShot()
        }
    }

    func setupShot(){
         if let urlString = self.shot?["shot"]["images"]["teaser"]{
            self.shotImage.sd_setImageWithURL(NSURL(string: urlString.stringValue), placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
        }
        self.shotImage.layer.cornerRadius = 5
        self.shotImage.clipsToBounds = true
    }
    
    func setupFollower(){
        self.typeView.layer.cornerRadius = 8
        self.typeView.clipsToBounds = true
        self.typeView.layer.borderWidth = 1
        self.typeView.layer.borderColor = UIColor.whiteColor().CGColor
        
        if let urlString = self.follower?["follower"]["avatar_url"]{
            print(urlString)
            self.avatarImageView.sd_setImageWithURL(NSURL(string: urlString.stringValue), placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
            self.avatarImageView.clipsToBounds = true
        }
        if let userName = self.follower!["follower"]["username"].string {
            self.userNameLabel.text = userName
        }
        if let location = self.follower!["follower"]["location"].string{
            self.locationLabel.text = location
        }
        if let type = self.follower!["follower"]["type"].string{
            if type == "Player" {
                if let pro = self.follower!["follower"]["pro"].bool {
                    if pro == true {
                        self.typeLabel.text = "Pro"
                        //self.typeView.backgroundColor = UIColor(rgba: "#F45081")
                        self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#798BF8"), UIColor(rgba: "#798BF8")])
                    }else{
                        self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#798BF8"), UIColor(rgba: "#798BF8")])
                        self.typeLabel.text = ""
                    }
                }
            }else if type == "Team" {
                self.typeLabel.text = "Team"
                self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#FFC27E"), UIColor(rgba: "#FFC27E")])
            }else {
                self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#FFC27E"), UIColor(rgba: "#FFC27E")])
                self.typeLabel.text = ""
            }
        }
    }
    
    func setupFollowee(){
        
        self.typeView.layer.cornerRadius = 8
        self.typeView.clipsToBounds = true
        self.typeView.layer.borderWidth = 1
        self.typeView.layer.borderColor = UIColor.whiteColor().CGColor
        
        if let urlString = self.followee?["followee"]["avatar_url"]{
            self.avatarImageView.sd_setImageWithURL(NSURL(string: urlString.stringValue), placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
            self.avatarImageView.clipsToBounds = true
            self.avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
            self.avatarImageView.layer.borderWidth = 2
        }
        if let userName = self.followee!["followee"]["username"].string {
            self.userNameLabel.text = userName
        }
        if let location = self.followee!["followee"]["location"].string{
            self.locationLabel.text = location
        }
        
        if let type = self.followee!["followee"]["type"].string{
            if type == "Player" {
                if let pro = self.followee!["followee"]["pro"].bool {
                    if pro == true {
                        self.typeLabel.text = "Pro"
                        //self.typeView.backgroundColor = UIColor(rgba: "#F45081")
                        self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#798BF8"), UIColor(rgba: "#798BF8")])
                    }else{
                        self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#798BF8"), UIColor(rgba: "#798BF8")])
                        self.typeLabel.text = ""
                    }
                }
            }else if type == "Team" {
                self.typeLabel.text = "Team"
                //self.typeView.backgroundColor = UIColor(rgba: "#37C1FF")
                //self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#7EDFB2"), UIColor(rgba: "#7EDFB2")])
                self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#FFC27E"), UIColor(rgba: "#FFC27E")])
                //self.typeViewWidth.constant = 35
            }else {
                self.typeView.backgroundColor = GradientColor(.LeftToRight, frame: self.typeView.frame, colors: [UIColor(rgba: "#FFC27E"), UIColor(rgba: "#FFC27E")])
                self.typeLabel.text = ""
            }
        }
    }
    
    func setupBukcets(){
        if let bucketName = self.bucket!["name"].string {
            self.bucketName.text = bucketName
        }
        if let sInt = self.bucket!["shots_count"].int {
            let sString = String(sInt)
            self.shotsCountLabel.text = sString
        }
    }
}
