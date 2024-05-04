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
            .on(.GET, "chatrooms", ":chatroomId", use: getChatroomList)
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
}
