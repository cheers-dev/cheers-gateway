//
//  UserGet.swift
//
//
//  Created by Dong on 2024/7/21.
//

import Fluent
import Vapor

extension User {
    struct Get: Content {
        let id: UUID
        let account: String
        let mail: String?
        let name: String
        var birth: Date?
        var avatar: URL?
    }
}
