//
//  ProjectShotsCollectionViewCell.swift
//  tassarim
//
//  Created by saylanc on 09/01/17.
//  Copyright © 2017 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Gifu
import SDWebImage

class ProjectShotsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var shotImage: UIImageView!
    @IBOutlet weak var gifView: AnimatableImageView!
    @IBOutlet weak var gifLabel: UIImageView!

    var shot:SwiftyJSON.JSON?{
        didSet{
            self.setupShot()
        }
    }
    
    func setupShot() {
        if let urlString = self.shot?["images"]["teaser"]{
            //let url = NSURL(string: urlString.stringValue)
            /*let fetcher = NetworkFetcher<UIImage>(URL: url!)
             let cache = Shared.imageCache
             
             cache.fetch(fetcher: fetcher).onSuccess { image in
             self.shotImage.image = image
             }*/
            
            //self.shotImage.hnk_setImageFromURL(url!)
            self.shotImage.sd_setImageWithURL(NSURL(string: urlString.stringValue), placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
            self.shotImage.layer.cornerRadius = 5
            self.shotImage.clipsToBounds = true
            /*self.shotImage.hnk_setImageFromURL(url!, placeholder: UIImage(named: ""), success: { (image) -> Void in
             self.shotImage.image = image
             }, failure: { (error) -> Void in
             })*/
            
            
            /*for gif
             let data = NSData(contentsOfURL: url!)
             self.gifView.animateWithImageData(data!)
             */
        }
        if let isAnimated = self.shot?["animated"] {
            let aBool = isAnimated
            if aBool {
                self.gifLabel.hidden = false
            }else{
                self.gifLabel.hidden = true
            }
        }
        /*
         let likeInt: Int = (self.shot!["likes_count"].int)!
         let likeString: String = String(likeInt)
         self.likeCountLabel.text = likeString
         
         let viewInt: Int = (self.shot!["views_count"].int)!
         let viewString: String = String(viewInt)
         self.viewCountLabel.text = viewString
         */
    }


}
