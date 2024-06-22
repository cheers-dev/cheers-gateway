//
//  ChatroomParticipant.swift
//  
//
//  Created by Dong on 2024/5/4.
//

import Fluent
import Vapor

final class ChatroomParticipant: Model, @unchecked Sendable {
    static let schema = "chatroom_participant"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "chatroom_id")
    var chatroom: Chatroom
    
    init() {}
    
    init(id: UUID? = nil, user: User, chatroom: Chatroom) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$chatroom.id = try chatroom.requireID()
    }
}
