//
//  ChatroomParticipantMigration.swift
//
//
//  Created by Dong on 2024/5/4.
//

import Fluent
import Vapor

struct ChatroomParticipantMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        do {
            try await database.schema(ChatroomParticipant.schema)
                .id()
                .field("user_id", .uuid, .required, .references("user", "id"))
                .field("chatroom_id", .uuid, .required, .references("chatroom", "id"))
                .unique(on: "user_id", "chatroom_id")
                .create()
        } catch(let err) {
            print(String(reflecting: err))
            throw Abort(.badRequest, reason: "\(err)")
        }
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(ChatroomParticipant.schema).delete()
    }
}
