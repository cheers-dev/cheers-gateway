//
//  UserInChatroom.swift
//
//
//  Created by Dong on 2024/5/7.
//

import Fluent
import Vapor

struct UserInChatroom {
    static func validation(
        req: Request,
        user: User,
        in chatroomId: UUID
    ) async throws -> ChatroomParticipant {
        
        let userInChatroom = try await ChatroomParticipant
            .query(on: req.db(.psql))
            .group { group in
                group.filter(\.$user.$id == user.id!)
                group.filter(\.$chatroom.$id == chatroomId)
            }
            .first()
        
        guard userInChatroom != nil
        else { throw Abort(.forbidden) }
        
        return userInChatroom!
    }
}
