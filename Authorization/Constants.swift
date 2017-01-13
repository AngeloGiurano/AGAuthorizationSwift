//
//  Constants.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/8/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation

public struct CONSTANTS {
    static let basePath = "http://api.anpost.ops-dev.pl/"

    static let client_id = "2_55ltqp8wo0u8w4ocgkoc8kowkg00gco4oc4osskgwgs4go00ks"
    static let client_secret = "avia4sc44lwocwok80ogw0k4owwg80cc0w4gw8wc4cc4c000c"
    
    struct AuthURLS {
        static let loginPath = basePath + "oauth/v2/token"
        static let registerPath = basePath + ""
        static let refreshTokenPath = basePath + "oauth/v2/token"
        static let forgotPasswordPath = basePath + ""
    }
    
    struct AuthKeys {
        static let CLIENT_ID = "client_id"
        static let CLIENT_SECRET = "client_secret"
        static let GRANT_TYPE = "grant_type"
        static let accessTokenKey = "access_token"
        static let refreshTokenKey = "refresh_token"
        static let expDateKey = "expires_in"
    }
    
    struct KeychainConstants {
        static let service = "com.returnpal.anpost"
        static let accessTokenKey = ""
        static let refreshTokenKey = ""
        static let expDateKey = ""
    }
}
