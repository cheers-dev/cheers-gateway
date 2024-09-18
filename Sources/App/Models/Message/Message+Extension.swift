//
//  Message+Extension.swift
//  cheers-gateway
//
//  Created by Dong on 9/19/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import FluentMongoDriver
import Vapor

extension Message {
    static func getMessageByChatroomID(
        _ req: Request,
        chatroomID: UUID,
        page: Int = 1
    ) async throws -> [Message] {
        try await Message
            .query(on: req.db(.mongo))
            .filter(\.$chatroomId == chatroomID)
            .sort(\.$createdAt, .descending)
            .paginate(PageRequest(page: page, per: 30))
            .items
    }
}
