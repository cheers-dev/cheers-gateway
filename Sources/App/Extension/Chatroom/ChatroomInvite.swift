//
//  ChatroomInvite.swift
//
//
//  Created by Dong on 2024/5/5.
//

import Fluent
import Vapor

extension Chatroom {
    struct Invite: Content {
        var userId: UUID
        var chatroomId: UUID
    }
}

extension Chatroom.Invite: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("userId", as: UUID.self, required: true)
        validations.add("chatroomId", as: UUID.self, required: true)
    }
}
