//
//  ChatroomMigration.swift
//
//
//  Created by Dong on 2024/5/4.
//

import Fluent
import Vapor

struct ChatroomMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        do {
            try await database.schema(Chatroom.schema)
                .id()
                .field("name", .string, .required)
                .field("avatar", .string, .required)
                .field("create_at", .datetime)
                .create()
        } catch(let err) {
            throw Abort(.badRequest, reason: "\(err)")
        }
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Chatroom.schema).delete()
    }
}

