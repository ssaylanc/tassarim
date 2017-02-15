//
//  ImageViewController.swift
//  tassarim
//
//  Created by saylanc on 31/10/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import Haneke

class ImageViewController: UIViewController {

    @IBOutlet weak var shotImageView: UIImageView!
    
    var shotURL: URL!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shotImageView.hnk_setImage(from: shotURL!)

        // Do any additional setup after loading the view.
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
