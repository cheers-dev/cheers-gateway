//
//  UserPreferenceMigration.swift
//
//
//  Created by 楊晏禎 on 2024/10/24.
//

import Fluent
import FluentKit
import Vapor

struct UserPreferenceMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        do {
            try await database.schema("user_preference")
                .field("user_id", .uuid, .identifier(auto: false), .references("user", "id"))
                .field("american", .int, .required)
                .field("chinese", .int, .required)
                .field("dessert", .int, .required)
                .field("japanese", .int, .required)
                .field("vietnamese", .int, .required)
                .field("italian", .int, .required)
                .field("korean", .int, .required)
                .field("hongkong", .int, .required)
                .field("thai", .int, .required)
                .field("french", .int, .required)
                .field("western", .int, .required)
                .field("southeastAsian", .int, .required)
                .field("exotic", .int, .required)
                .field("bar", .int, .required)
                .create()
        } catch {
            throw Abort(.badRequest, reason: "\(error)")
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema("user_preference").delete()
    }
}
