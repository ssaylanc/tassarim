//
//  Analytics.swift
//  tassarim
//
//  Created by saylanc on 02/01/17.
//  Copyright © 2017 saylanc. All rights reserved.
//

import Foundation

class GAnalytics {
    
    static let sharedInstance = GAnalytics()
    
    func sendScreenTracking(screenName: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screenName)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func trackAction(category: String, action: String, label: String, value: NSNumber?) {
        let tracker = GAI.sharedInstance().defaultTracker
        let builder = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value)
        tracker?.send(builder.build() as [NSObject : AnyObject])
    }
}