//
//  FriendMigration.swift
//
//
//  Created by Dong on 2024/6/26.
//

import Fluent
import Vapor

struct FriendMigration: AsyncMigration {
    
    func prepare(on database: any FluentKit.Database) async throws {
        do {
            try await database.schema("friend")
                .id()
                .field("uid1", .uuid, .required, .references("user", "id"))
                .field("uid2", .uuid, .required, .references("user", "id"))
                .field("create_at", .datetime)
                .unique(on: "uid1", "uid2")
                .create()
        } catch {
            throw Abort(.badRequest, reason: "\(error)")
        }
    }

    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("friend").delete()
    }

}
