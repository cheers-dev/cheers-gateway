//
//  User+Extension.swift
//  cheers-gateway
//
//  Created by Dong on 9/16/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

extension User {
    static func getMessageWithSender(
        _ req: Request,
        message: Message
    ) async throws -> Message.Get {
        guard let user = try await User
            .query(on: req.db(.psql))
            .filter(\.$id == message.userId)
            .first(),
            let messageSendTime = message.createdAt
        else { throw Abort(.noContent) }

        return try Message.Get(
            id: message.requireID(),
            user: User.Get(
                id: user.requireID(),
                account: user.account,
                mail: user.mail,
                name: user.name
            ),
            content: message.content,
            createAt: messageSendTime
        )
    }
}
