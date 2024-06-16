//
//  MessageMigration.swift
//  
//
//  Created by Dong on 2024/6/3.
//

import Fluent
import Vapor

struct MessageMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        do {
            try await database.schema("message")
                .id()
                .field("userId", .uuid, .required, .references("user", "id"))
                .field("chatroomId", .uuid, .required, .references("chatroom", "id"))
                .field("content", .string, .required)
                .field("createdAt", .datetime)
                .create()
        } catch(let err) {
            throw Abort(.badRequest, reason: String(describing: err))
        }
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Message.schema).delete()
    }
}
