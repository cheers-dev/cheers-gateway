//
//  Friend.swift
//  cheers-gateway
//
//  Created by Dong on 6/25/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

final class Friend: Model, Content, @unchecked Sendable {
    static let schema = "friend"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "uid1")
    var uid1: User
    
    @Parent(key: "uid2")
    var uid2: User
    
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, uid1: User, uid2: User) throws {
        self.id = id
        self.$uid1.id = try uid1.requireID()
        self.$uid2.id = try uid2.requireID()
    }
}
