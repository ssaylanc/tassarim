//
//  CommentsTableViewCell.swift
//  tassarim
//
//  Created by saylanc on 05/12/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke
import SDWebImage


class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var designerButton: UIButton!

    var comments:SwiftyJSON.JSON?{
        didSet{
            self.setupComments()
        }
    }
    
    func setupComments(){
        if let tLabel = self.comments?["user"]["name"].string {
            self.userName.text = tLabel
        }else {
            self.userName.text = "Başlık Alınamadı"
        }
        /*if let urlString = self.comments?["user"]["avatar_url"]{
            let url = NSURL(string: urlString.stringValue)
            
            let fetcher = NetworkFetcher<UIImage>(URL: url!)
            let cache = Shared.imageCache
            
            cache.fetch(fetcher: fetcher).onSuccess { image in
                self.userAvatarImage.image = image
                self.userAvatarImage.hnk_setImageFromURL(url!)
                self.userAvatarImage.layer.cornerRadius = self.userAvatarImage.frame.size.width/2
                self.userAvatarImage.clipsToBounds = true
            }
        }*/
        
        if let imageURL = self.comments?["user"]["avatar_url"] {
            //let url = NSURL(string: imageURL.stringValue)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //self.userAvatarImage.hnk_setImageFromURL(url!)
                self.userAvatarImage.sd_setImageWithURL(NSURL(string: imageURL.stringValue), placeholderImage:UIImage(contentsOfFile:"placeholder.png"))
                self.userAvatarImage.layer.cornerRadius = self.userAvatarImage.frame.size.width/2
                self.userAvatarImage.layer.borderWidth = 2
                self.userAvatarImage.layer.borderColor = UIColor.whiteColor().CGColor
                self.userAvatarImage.clipsToBounds = true
            })
        }
    
        if let tLabel = self.comments?["body"].string {
            //http://stackoverflow.com/questions/25879837/how-to-display-html-formatted-text-in-ios-label
            let attrStr = try! NSAttributedString(
                data: tLabel.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            self.commentLabel.attributedText = attrStr
            self.commentLabel.font = commentLabel.font.fontWithSize(16)
        }else {
            self.commentLabel.text = "Başlık Alınamadı"
        }
    }
}
