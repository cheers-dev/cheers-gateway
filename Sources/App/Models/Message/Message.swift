//
//  Message.swift
//  cheers-gateway
//
//  Created by Dong on 5/4/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import MongoKitten
import Vapor

final class Message: Model, Content, @unchecked Sendable {
    static let schema = "message"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userId")
    var userId: UUID

    @Field(key: "chatroomId")
    var chatroomId: UUID
        
    @Field(key: "content")
    var content: String
    
    @Field(key: "createdAt")
    var createdAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, userId: UUID, chatroomId: UUID, content: String, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.chatroomId = chatroomId
        self.content = content
        self.createdAt = createdAt
    }
}
