//
//  User.swift
//  cheers-gateway
//
//  Created by Dong on 3/27/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "user"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "account")
    var account: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "mail")
    var mail: String
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "birth")
    var birth: Date?
    
    @OptionalField(key: "avatar")
    var avatar: URL?
    
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    
    @Children(for: \.$requestor)
    var requestedInvitations: [FriendInvitation]
    
    @Children(for: \.$addressee)
    var receivedInvitations: [FriendInvitation]
    
    @Siblings(through: ChatroomParticipant.self, from: \.$user, to: \.$chatroom)
    var chatrooms: [Chatroom]
    
    @Siblings(through: Friend.self, from: \.$uid1, to: \.$uid2)
    private var friendList1: [User]
    
    @Siblings(through: Friend.self, from: \.$uid2, to: \.$uid1)
    private var friendList2: [User]
    
    var friends: [User] {
        return friendList1 + friendList2
    }
    
    init() {}
    
    init(id: UUID? = nil, account: String, hashedPassword: String, mail: String, name: String, birthString: String, avatar: URL? = nil) throws {
        self.id = id
        self.account = account
        self.password = hashedPassword
        self.mail = mail
        self.name = name
        self.avatar = avatar
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .init(identifier: "Asia/Taipei")
        
        guard let birth = dateFormatter.date(from: birthString)
        else {
            throw Abort(.badRequest, reason: "Invalid date format.")
        }
        
        self.birth = birth
    }
}
