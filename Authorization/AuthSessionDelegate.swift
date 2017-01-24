//
//  AuthSessionDelegate.swift
//  Authorization
//
//  Created by Angelo Giurano on 1/14/17.
//  Copyright © 2017 OpsTalent. All rights reserved.
//

import Foundation

public protocol AuthSessionDelegate: class {
    func sessionDidLogin()
    func sessionDidLogout()
    func refreshTokenFailed(with error: Error)
    func sessionDidRefreshToken()
}
