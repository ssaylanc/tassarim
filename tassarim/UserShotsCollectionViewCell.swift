//
//  UserShotsCollectionViewCell.swift
//  tassarim
//
//  Created by saylanc on 08/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import RandomColorSwift

class UserShotsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shotImage: UIImageView!
    @IBOutlet weak var memberAvatar: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var projectDescLabel: UILabel!
    @IBOutlet weak var shotsCount: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var projectIcon: UIImageView!

    var shot:JSON?{
        didSet{
            self.setupShot()
        }
    }
    
    var members:JSON?{
        didSet{
            self.setupMembers()
        }
    }
    
    var projects:JSON?{
        didSet{
            self.setupProjects()
        }
    }
    
    func setupShot() {
        if let urlString = self.shot?["images"]["teaser"]{
            //let url = NSURL(string: urlString.stringValue)
            //self.shotImage.hnk_setImageFromURL(url!)
            self.shotImage.sd_setImage(with: URL(string: urlString.stringValue), placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
            /*for gif
             let data = NSData(contentsOfURL: url!)
             self.gifView.animateWithImageData(data!)
             */
            self.shotImage.layer.cornerRadius = 5
            self.shotImage.clipsToBounds = true
        }
    }
    
    func setupMembers() {
        if let urlString = self.members?["avatar_url"]{
            self.memberAvatar.sd_setImage(with: URL(string: urlString.stringValue), placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
            self.memberAvatar.layer.cornerRadius = 25
            self.memberAvatar.clipsToBounds = true
        }
    }
    
    func setupProjects() {
        self.projectNameLabel.text = self.projects?["name"].string
        //self.projectDescLabel.text = self.projects?["description"].string
        if let cInt = self.projects?["shots_count"] {
            let cString = String(describing: cInt)
            self.shotsCount.text = cString
        }

    }
}
