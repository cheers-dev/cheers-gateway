//
//  ChatroomCreate.swift
//  
//
//  Created by Dong on 2024/5/4.
//

import Fluent
import Vapor

extension Chatroom {
    struct Create: Content {
        var avatar: URL?
        var name: String
        var userIds: [UUID]
    }
}

extension Chatroom.Create: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("avatar", as: URL.self)
        validations.add("name", as: String.self, is: !.empty, required: true)
        validations.add("userIds", as: [UUID].self, required: true)
    }
}
