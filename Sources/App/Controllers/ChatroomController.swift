//
//  ChatroomController.swift
//
//
//  Created by Dong on 2024/5/3.
//

import Fluent
import FluentMongoDriver
import Vapor

struct ChatroomController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let chatroom = routes
            .grouped("chat")
            .grouped(AccessToken.authenticator())
        
        chatroom.on(.GET, "chatrooms", use: getChatroomList)
        chatroom.on(.POST, "createChatroom", use: createChatroom)
        chatroom.on(.POST, "invite", use: inviteUser)
        chatroom.on(.DELETE, "leave", ":chatroomId", use: leaveChatroom)
        chatroom.on(.GET, "messages", ":chatroomId", use: getMessages)
    }
    
    func getChatroomList(req: Request) async throws -> [Chatroom.Info] {
        let user = try req.auth.require(User.self)
        return try await ChatroomParticipant.getAllUserChatroomInfos(req, userId: user.requireID())
    }
    
    func createChatroom(req: Request) async throws -> Chatroom {
        try Chatroom.Create.validate(content: req)
        let data = try req.content.decode(Chatroom.Create.self)
        let chatroom = try await Chatroom.createChatroom(req, name: data.name)
        
        for userId in data.userIds {
            try await ChatroomParticipant
                .addUserToChatroom(req, userID: userId, chatroom: chatroom)
        }
        
        return chatroom
    }
    
    func inviteUser(req: Request) async throws -> Response {
        let inviter = try req.auth.require(User.self)
        
        try Chatroom.Invite.validate(content: req)
        let data = try req.content.decode(Chatroom.Invite.self)
        
        guard try await Friend.verifyFriend(req, between: inviter, and: data.userId)
        else { throw Abort(.forbidden, reason: "Friend not exist.") }
        
        guard try await ChatroomParticipant
            .verifyUserInChatroom(req, user: inviter, in: data.chatroomId)
        else { throw Abort(.forbidden, reason: "Permission denied.") }
        
        guard let user = try await User
            .query(on: req.db(.psql))
            .filter(\.$id == data.userId)
            .first()
        else { return Response(status: .forbidden) }
        
        try await ChatroomParticipant.addUserToChatroom(
            req,
            userID: data.userId,
            chatroomID: data.chatroomId
        )
        
        return Response(status: .ok)
    }
    
    func leaveChatroom(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        
        guard let chatroomId = UUID(uuidString: req.parameters.get("chatroomId")!)
        else { throw Abort(.badRequest) }
        
        try await ChatroomParticipant.removeUserFromChatroom(req, user: user, from: chatroomId)
        
        return Response(status: .ok)
    }
    
    func getMessages(req: Request) async throws -> [Message] {
        let user = try req.auth.require(User.self)
        
        guard let chatroomId = UUID(uuidString: req.parameters.get("chatroomId")!)
        else { throw Abort(.badRequest) }
        
        let page = Int(req.query["page"] ?? 1)
        
        guard try await ChatroomParticipant.verifyUserInChatroom(req, user: user, in: chatroomId)
        else { throw Abort(.forbidden, reason: "User not in chatroom") }
        
        return try await Message.getMessageByChatroomID(req, chatroomID: chatroomId, page: page)
    }
}
