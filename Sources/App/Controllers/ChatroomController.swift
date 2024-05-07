//
//  ChatroomController.swift
//  
//
//  Created by Dong on 2024/5/3.
//

import Fluent
import Vapor



struct ChatroomController {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let chatroom = routes.grouped("chat")
        
        chatroom
            .grouped(AccessToken.authenticator())
            .on(.GET, "chatrooms", use: getChatroomList)
        
        chatroom
            .grouped(AccessToken.authenticator())
            .on(.POST, "createChatroom", use: createChatroom)
        
        chatroom
            .grouped(AccessToken.authenticator())
            .on(.POST, "invite", use: inviteUser)
    }
    
    func getChatroomList(req: Request) async throws -> [ChatroomInfo] {
        let user = try req.auth.require(User.self)
        
        var userInChatrooms = try await ChatroomParticipant
            .query(on: req.db(.psql))
            .filter(\.$user.$id == user.id!)
            .all()
        
        var chatroomInfos: [ChatroomInfo] = []
        for userInChatroom in userInChatrooms {
            let lastMessage = try await Message
                .query(on: req.db(.mongo))
                .filter(\.$userId == user.id!)
                .sort(\.$createAt, .descending)
                .first()
            
            chatroomInfos.append(ChatroomInfo(
                chatroom: userInChatroom.chatroom,
                lastMessage: lastMessage
            ))
        }
        
        return chatroomInfos.sorted {
            guard let lhsMessage = $0.lastMessage,
                  let lhsTime = lhsMessage.createAt
            else { return false }
            
            guard let rhsMessage = $1.lastMessage,
                  let rhsTime = rhsMessage.createAt
            else { return false }
            
            return lhsTime > rhsTime
        }
    }
    
    func createChatroom(req: Request) async throws -> Chatroom {
        try Chatroom.Create.validate(content: req)
        let data = try req.content.decode(Chatroom.Create.self)
        
        let chatroom = Chatroom(name: data.name)
        try await chatroom.save(on: req.db(.psql))
        
        for userId in data.userIds {
            guard let user = try await User
                      .query(on: req.db)
                      .filter(\.$id == userId)
                      .first()
            else { throw Abort(.badRequest, reason: "User not found.")}
            
            let participant = try ChatroomParticipant(user: user, chatroom: chatroom)
            try await participant.save(on: req.db(.psql))
        }
        
        return chatroom
    }
    
    func inviteUser(req: Request) async throws -> Response {
        let inviter = try req.auth.require(User.self)
        
        try Chatroom.Invite.validate(content: req)
        let data = try req.content.decode(Chatroom.Invite.self)
        
        guard let chatroom = try await Chatroom
            .query(on: req.db(.psql))
            .filter(\.$id == data.chatroomId)
            .first()
        else { return Response(status: .forbidden) }
        
        let inviterInChatroom = try await ChatroomParticipant
            .query(on: req.db(.psql))
            .group(.and) { group in
                group
                    .filter(\.$user.$id == inviter.id!)
                    .filter(\.$chatroom.$id == chatroom.id!)
            }
            .first()
        
        guard inviterInChatroom != nil
        else { return Response(status: .nonAuthoritativeInformation) }
        
        guard let user = try await User
            .query(on: req.db(.psql))
            .filter(\.$id == data.userId)
            .first()
        else { return Response(status: .forbidden) }
        
        let participant = try ChatroomParticipant(user: user, chatroom: chatroom)
        try await participant.save(on: req.db(.psql))

        return Response(status: .accepted)
    }
}
