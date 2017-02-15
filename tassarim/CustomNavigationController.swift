//
//  CustomNavigationController.swift
//  tassarim
//
//  Created by saylanc on 22/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import UIKit
import QuartzCore

extension CAGradientLayer {
    class func gradientLayerForBounds(_ bounds: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = [UIColor.blue.cgColor, UIColor.white.cgColor]
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        return layer
    }
}

class CustomNavigationController: UINavigationController {

    fileprivate func imageLayerForGradientBackground() -> UIImage {
        
        var updatedFrame = self.navigationBar.bounds
        // take into account the status bar
        updatedFrame.size.height += 20
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = UIColor.white
        let fontDictionary = [ NSForegroundColorAttributeName:UIColor.white ]
        self.navigationBar.titleTextAttributes = fontDictionary
        self.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
    }
}
