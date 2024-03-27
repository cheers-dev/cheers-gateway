//
//  CreateUser.swift
//
//
//  Created by Dong on 2024/3/27.
//

import Fluent
import Vapor

struct CreateUser: AsyncMigration {

    func prepare(on database: any FluentKit.Database) async throws {
        do {
            try await database.schema("user")
                .id()
                .field("account", .string, .required)
                .field("mail", .string, .required)
                .field("password", .string, .required)
                .field("name", .string, .required)
                .field("birth", .date)
                .field("avatar", .string)
                .unique(on: "account")
                .unique(on: "mail")
                .create()
        } catch(let err) {
            throw Abort(.badRequest, reason: err.localizedDescription)
        }
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("user").delete()
    }
}
