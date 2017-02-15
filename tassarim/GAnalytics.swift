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
    
    func sendScreenTracking(_ screenName: String) {
        /*let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
        let builder = GAIDictionaryBuilder.createScreenView()
        //tracker?.send(builder?.build() as [AnyHashable: Any])
        tracker?.send(builder?.build())*/
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: screenName)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])

    }
    
    func trackAction(_ category: String, action: String, label: String, value: NSNumber?) {
        /*let tracker = GAI.sharedInstance().defaultTracker
        let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
        tracker?.send(builder?.build() as [AnyHashable: Any])*/
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        guard let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value) else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
}
