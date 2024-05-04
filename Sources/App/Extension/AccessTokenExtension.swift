//
//  AccessTokenExtension.swift
//  
//
//  Created by Dong on 2024/5/3.
//

import Fluent
import Vapor

extension AccessToken: ModelTokenAuthenticatable {
    static let valueKey = \AccessToken.$token
    static let userKey = \AccessToken.$user
    
    var isValid: Bool { true }
}
