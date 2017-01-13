//
//  OAuthResponse.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/9/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//

import Foundation
import ObjectMapper
import KeychainAccess
import DateTools

final class OAuthResponse: Mappable {
    
    fileprivate var authToken: String?
    fileprivate var refreshToken: String?
    fileprivate var expiresIn: Int?
    
    required init?(map: Map) {
        guard let authToken = map.JSON[CONSTANTS.AuthKeys.accessTokenKey] as? String, let refreshToken = map.JSON[CONSTANTS.AuthKeys.refreshTokenKey] as? String, let expDate = map.JSON[CONSTANTS.AuthKeys.expDateKey] as? Int else {
            return nil
        }
        
        Keychain.sharedInstance.setValue(value: authToken, forKey: CONSTANTS.KeychainConstants.accessTokenKey)
        Keychain.sharedInstance.setValue(value: refreshToken, forKey: CONSTANTS.KeychainConstants.refreshTokenKey)
        let date = NSDate().addingSeconds(expDate).timeIntervalSince1970
        Keychain.sharedInstance.setValue(value: "\(date)", forKey: CONSTANTS.KeychainConstants.expDateKey)
    }
    
    init() {
        self.authToken = Keychain.sharedInstance.accessToken
        self.refreshToken = Keychain.sharedInstance.refreshToken
        self.expiresIn = 3600
    }
    
    func mapping(map: Map) {
        authToken <- map[CONSTANTS.AuthKeys.accessTokenKey]
        refreshToken <- map[CONSTANTS.AuthKeys.refreshTokenKey]
        expiresIn <- map[CONSTANTS.AuthKeys.expDateKey]
    }
}
