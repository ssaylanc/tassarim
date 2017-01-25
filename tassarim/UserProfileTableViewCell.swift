//
//  UserProfileTableViewCell.swift
//  tassarim
//
//  Created by saylanc on 16/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
   
    @IBOutlet weak var bucketsCount: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    
    @IBOutlet weak var contactAdress: UILabel!
    @IBOutlet weak var contactView: UIView!
    
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var twitterLabel: UILabel!
    
    var profile:SwiftyJSON.JSON?{
        didSet{
            self.setupProfile()
        }
    }
    
    var contact:SwiftyJSON.JSON?{
        didSet{
            self.setupContact()
        }
    }

    func setupProfile(){
    
    }
    
    func setupContact(){
    
    }
}
