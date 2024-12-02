//
//  ChatroomController.swift
//
//
//  Created by Dong on 2024/5/3.
//

import Fluent
import FluentMongoDriver
import Vapor

// MARK: - ChatroomController

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
        chatroom.on(.GET, "recommendation", ":chatroomId", use: getRecommendation)
        chatroom.on(.GET, "recommendationList", use: getRecommendationList)
    }
}

extension ChatroomController {
    private func getChatroomList(req: Request) async throws -> [Chatroom.Info] {
        let user = try req.auth.require(User.self)
        return try await ChatroomParticipant.getAllUserChatroomInfos(req, userId: user.requireID())
    }
    
    private func createChatroom(req: Request) async throws -> Chatroom {
        try Chatroom.Create.validate(content: req)
        let data = try req.content.decode(Chatroom.Create.self)
        let chatroom = try await Chatroom.createChatroom(req, name: data.name)
        
        for userId in data.userIds {
            try await ChatroomParticipant
                .addUserToChatroom(req, userID: userId, chatroom: chatroom)
        }
        
        return chatroom
    }
    
    private func inviteUser(req: Request) async throws -> Response {
        let inviter = try req.auth.require(User.self)
        
        try Chatroom.Invite.validate(content: req)
        let data = try req.content.decode(Chatroom.Invite.self)
        
        guard try await Friend.verifyFriend(req, between: inviter, and: data.userId)
        else { throw Abort(.forbidden, reason: "Friend not exist.") }
        
        guard try await ChatroomParticipant
            .verifyUserInChatroom(req, user: inviter, in: data.chatroomId)
        else { throw Abort(.forbidden, reason: "Permission denied.") }
        
        try await ChatroomParticipant.addUserToChatroom(
            req,
            userID: data.userId,
            chatroomID: data.chatroomId
        )
        
        return Response(status: .ok)
    }
    
    private func leaveChatroom(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        
        guard let chatroomId = UUID(uuidString: req.parameters.get("chatroomId")!)
        else { throw Abort(.badRequest) }
        
        try await ChatroomParticipant.removeUserFromChatroom(req, user: user, from: chatroomId)
        
        return Response(status: .ok)
    }
    
    private func getMessages(req: Request) async throws -> [MessageWithSender] {
        let user = try req.auth.require(User.self)
        
        guard let chatroomId = UUID(uuidString: req.parameters.get("chatroomId")!)
        else { throw Abort(.badRequest) }
        
        let page = Int(req.query["page"] ?? 1)
        
        guard try await ChatroomParticipant.verifyUserInChatroom(req, user: user, in: chatroomId)
        else { throw Abort(.forbidden, reason: "User not in chatroom") }
        
        var messages = try await Message.getMessageByChatroomID(req, chatroomID: chatroomId, page: page)
        
        var messagesWithSender: [MessageWithSender] = []
        for message in messages {
            guard let sender = try await User.find(message.userId, on: req.db(.psql)) else {
                throw Abort(.notFound, reason: "Sender not found")
            }
            
            let messageWithSender = MessageWithSender(
                id: message.id!,
                userId: message.userId,
                chatroomId: message.chatroomId,
                content: message.content,
                createdAt: message.createdAt,
                name: sender.name
//                avatar: sender.avatar
            )
                    
            messagesWithSender.append(messageWithSender)
        }
        
        return messagesWithSender
    }
    
    private func getRecommendation(req: Request) async throws -> [RestaurantRecommendation]{
        let user = try req.auth.require(User.self)
        
        guard let chatroomId = UUID(uuidString: req.parameters.get("chatroomId")!)
        else { throw Abort(.badRequest) }
        
        let page = Int(req.query["page"] ?? 1)
        
        guard try await ChatroomParticipant.verifyUserInChatroom(req, user: user, in: chatroomId)
        else { throw Abort(.forbidden, reason: "User not in chatroom") }
        
        let recommendation = try await Recommendation
            .query(on: req.db(.mongo))
            .filter(\.$chatroomId == chatroomId)
            .first()
        
        guard let recommendations = recommendation?.recommendation else {
            return []
        }
        
        // 計算每個推薦餐廳的 likes 和 dislikes
        return recommendations.map { recommendation in
                
            let like_status = recommendation.like_status ?? []
            let likes = like_status.filter { $0.like }.count
            let dislikes = like_status.filter { !$0.like }.count
                
            return RestaurantRecommendation(
                opening_time: recommendation.opening_time,
                name: recommendation.name,
                category: recommendation.category,
                rating: recommendation.rating,
                address: recommendation.address,
                phone: recommendation.phone,
                price: recommendation.price,
                like_status: like_status,
                likes: likes,
                dislikes: dislikes
            )
        }
    }
    
    private func getRecommendationList(req: Request) async throws -> [Recommendation.Info] {
        let user = try req.auth.require(User.self)
        return try await ChatroomParticipant.getAllUserRecommendations(req, userId: user.requireID())
    }
}