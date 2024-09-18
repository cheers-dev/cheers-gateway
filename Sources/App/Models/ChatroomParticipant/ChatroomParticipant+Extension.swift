//
//  ChatroomParticipant+Extension.swift
//  cheers-gateway
//
//  Created by Dong on 9/18/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

extension ChatroomParticipant {
    static func getAllUserChatroomInfos(
        _ req: Request,
        userId: UUID
    ) async throws -> [Chatroom.Info] {
        let userChatrooms = try await ChatroomParticipant
            .query(on: req.db(.psql))
            .filter(\.$user.$id == userId)
            .with(\.$chatroom)
            .all()

        var chatroomInfos = [Chatroom.Info]()
        for userChatroom in userChatrooms {
            let lastMessage = try await Message
                .query(on: req.db(.mongo))
                .filter(\.$chatroomId == userChatroom.requireID())
                .sort(\.$createdAt, .descending)
                .first()

            chatroomInfos.append(Chatroom.Info(
                chatroom: userChatroom.chatroom,
                lastMessage: lastMessage
            ))
        }

        return chatroomInfos.sorted {
            guard let lhs = $0.lastMessage?.createdAt,
                  let rhs = $1.lastMessage?.createdAt
            else { return false }

            return lhs > rhs
        }
    }

    static func addUserToChatroom(
        _ req: Request,
        userID: UUID,
        chatroom: Chatroom
    ) async throws {
        guard let user = try await User.find(userID, on: req.db(.psql))
        else { throw Abort(.forbidden, reason: "Permission denied") }

        let participant = try ChatroomParticipant(user: user, chatroom: chatroom)
        try await participant.save(on: req.db(.psql))
    }

    static func addUserToChatroom(
        _ req: Request,
        userID: UUID,
        chatroomID: UUID
    ) async throws {
        guard let user = try await User.find(userID, on: req.db(.psql)),
              let chatroom = try await Chatroom.find(chatroomID, on: req.db(.psql))
        else { throw Abort(.forbidden, reason: "Permission denied") }

        let participant = try ChatroomParticipant(user: user, chatroom: chatroom)
        try await participant.save(on: req.db(.psql))
    }

    static func verifyUserInChatroom(
        _ req: Request,
        user: User,
        in chatroomID: UUID
    ) async throws -> Bool {
        let chatroomParticipant = try await ChatroomParticipant
            .query(on: req.db(.psql))
            .filter(\.$user.$id == user.requireID())
            .filter(\.$chatroom.$id == chatroomID)
            .first()

        return chatroomParticipant != nil
    }

    static func removeUserFromChatroom(
        _ req: Request,
        user: User,
        from chatroomID: UUID
    ) async throws {
        try await ChatroomParticipant
            .query(on: req.db(.psql))
            .filter(\.$user.$id == user.requireID())
            .filter(\.$chatroom.$id == chatroomID)
            .delete()
    }
}
