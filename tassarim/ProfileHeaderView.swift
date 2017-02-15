//
//  ProfileHeaderView.swift
//  tassarim
//
//  Created by saylanc on 19/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileHeaderView: UICollectionReusableView {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var isProLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBAction func segmentedControlAction(_ sender: AnyObject) {
       
    }
    
    
    var userID: Int!
    var avatarImageURL: URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


extension ProfileHeaderView {
    func setAvatar(_ url: URL){
        self.avatarImage.hnk_setImage(from: url)
        self.avatarImage.layer.cornerRadius = 30
        self.avatarImage.clipsToBounds = true
    }
}

extension CALayer {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        mask = shape
    }
}
