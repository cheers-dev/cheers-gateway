//
//  Chatroom.swift
//  cheers-gateway
//
//  Created by Dong on 5/3/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

final class Chatroom: Model, Content, @unchecked Sendable {
    static let schema = "chatroom"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "avatar")
    var avatar: URL?
    
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    
    @Siblings(through: ChatroomParticipant.self, from: \.$chatroom, to: \.$user)
    var users: [User]
    
    init() {}
    
    init(id: UUID? = nil, name: String, avatar: URL? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
    }
}
