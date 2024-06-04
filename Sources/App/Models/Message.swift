//
//  Message.swift
//  
//
//  Created by Dong on 2024/5/4.
//

import Fluent
import MongoKitten
import Vapor

final class Message: Model, Content {
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
