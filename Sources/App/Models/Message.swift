//
//  Message.swift
//  
//
//  Created by Dong on 2024/5/4.
//

import Fluent

final class Message: Model {
    static let schema = "message"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userId")
    var userId: UUID

    @Field(key: "chatroomId")
    var chatroomId: UUID
    	
    @Field(key: "message")
    var message: String
    
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    
    init() {}
    
    init(id: UUID, userId: UUID, chatroomId: UUID, message: String) {
        self.id = id
        self.userId = userId
        self.chatroomId = chatroomId
        self.message = message
    }
}
