//
//  FriendInvitationMigration.swift
//
//
//  Created by Dong on 2024/6/26.
//

import Fluent
import Vapor

struct FriendInvitationMigration: AsyncMigration {
    
    func prepare(on database: any FluentKit.Database) async throws {
        do {
            try await database.schema(FriendInvitation.schema)
                .id()
                .field("requester", .uuid, .required, .references("user", "id"))
                .field("addressee", .uuid, .required, .references("user", "id"))
                .field("status", .string, .required)
                .field("create_at", .datetime)
                .field("update_at", .datetime)
                .create()
        } catch {
            throw Abort(.badRequest, reason: "\(error)")
        }
    }

    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema(FriendInvitation.schema).delete()
    }

}
