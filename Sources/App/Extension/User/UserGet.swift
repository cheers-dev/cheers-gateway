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
        var account: String
        var mail: String?
        var name: String
        var birth: Date?
        var avatar: URL?
    }
}
