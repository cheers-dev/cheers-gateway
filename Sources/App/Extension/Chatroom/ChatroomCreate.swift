//
//  ChatroomCreate.swift
//
//
//  Created by Dong on 2024/5/4.
//

import Fluent
import Vapor

// MARK: - Chatroom.Create

extension Chatroom {
    struct Create: Content {
        var avatar: URL?
        var name: String
        var userIds: [UUID]
    }
}

// MARK: - Chatroom.Create + Validatable

extension Chatroom.Create: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("avatar", as: URL.self, required: false)
        validations.add("name", as: String.self, is: !.empty)
        validations.add("userIds", as: [UUID].self)
    }
}
