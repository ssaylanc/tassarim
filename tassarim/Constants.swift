//
//  Constants.swift
//  tassarim
//
//  Created by saylanc on 24/11/16.
//  Copyright © 2016 saylanc. All rights reserved.
//

import Foundation
import OAuthSwift

let oauthswift = OAuth2Swift(
    consumerKey:    "4cf827eca84b70b9edbcbc053f28ee93f517fbd8e26cc52038950a593f69262b",
    consumerSecret: "dd240ac0423d35d8177710fadd9acbb434021734d88bad65e7284ed667bb0282",
    authorizeUrl:   "https://dribbble.com/oauth/authorize",
    accessTokenUrl: "https://dribbble.com/oauth/token",
    responseType:   "code"
)