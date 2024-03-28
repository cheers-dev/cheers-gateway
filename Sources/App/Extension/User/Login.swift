//
//  Login.swift
//
//
//  Created by Dong on 2024/3/28.
//

import Fluent
import Vapor

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$account
    static let passwordHashKey = \User.$hashedPassword
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.hashedPassword)
    }
    
    func generateAccessToken() throws -> AccessToken {
        try .init(
            token: [UInt8].random(count: 32).base64,
            userId: self.requireID()
        )
    }
}
