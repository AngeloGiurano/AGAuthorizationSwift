//
//  AuthSessionDelegate.swift
//  Authorization
//
//  Created by Angelo Giurano on 1/14/17.
//  Copyright © 2017 OpsTalent. All rights reserved.
//

import Foundation

protocol AuthSessionDelegate: class {
    func refreshTokenFailed(with error: Error)
    func sessionDidRefreshToken()
}
