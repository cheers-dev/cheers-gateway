//
//  UserPreferenceMigration.swift
//
//
//  Created by 楊晏禎 on 2024/10/24.
//

import Fluent

struct UserPreferenceMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_preference")
            .field("user_id", .uuid, .identifier(auto: false))
            .field("美式", .int, .required)
            .field("中式", .int, .required)
            .field("甜點", .int, .required)
            .field("日式", .int, .required)
            .field("越式", .int, .required)
            .field("義式", .int, .required)
            .field("韓式", .int, .required)
            .field("港式", .int, .required)
            .field("泰式", .int, .required)
            .field("法式", .int, .required)
            .field("西式", .int, .required)
            .field("東南亞", .int, .required)
            .field("異國料理", .int, .required)
            .field("酒吧", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_preference").delete()
    }
}

