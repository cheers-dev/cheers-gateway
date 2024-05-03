//
//  AccessTokenMigration.swift
//
//
//  Created by Dong on 2024/3/28.
//

import Fluent
import Vapor

struct AccessTokenMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        do {
            try await database.schema("access_token")
                .id()
                .field("token", .string, .required)
                .field("user_id", .uuid, .required, .references("user", "id"))
                .unique(on: "token")
                .unique(on: "user_id")
                .create()
        } catch(let err) {
            throw Abort(.badRequest, reason: "\(err)")
        }
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("access_token").delete()
    }
}
