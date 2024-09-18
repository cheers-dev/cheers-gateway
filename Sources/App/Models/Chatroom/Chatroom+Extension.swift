//
//  Chatroom+Extension.swift
//  cheers-gateway
//
//  Created by Dong on 9/18/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

extension Chatroom {
    static func createChatroom(
        _ req: Request,
        name: String,
        avatar: URL? = nil
    ) async throws -> Chatroom {
        let chatroom = Chatroom(id: UUID(), name: name, avatar: avatar)
        try await chatroom.save(on: req.db(.psql))
        return chatroom
    }
}
