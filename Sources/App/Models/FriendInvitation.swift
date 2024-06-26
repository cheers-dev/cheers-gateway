//
//  FriendInvitation.swift
//
//
//  Created by Dong on 2024/6/25.
//

import Fluent
import Vapor

final class FriendInvitation: Model, Content, @unchecked Sendable {
    static let schema = "friend_invitation"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "requester_id")
    var requestor: User
    
    @Parent(key: "addressee_id")
    var addressee: User
    
    @Enum(key: "status")
    var status: FriendInvitation.Status
    
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    
    @Timestamp(key: "update_at", on: .update)
    var updateAt: Date?
    
    init() {}
    
    init(
        id: UUID? = nil,
        requestor: User,
        addressee: User,
        status: FriendInvitation.Status = .pending
    ) {
        self.id = id
        self.requestor = requestor
        self.addressee = addressee
        self.status = status
    }
}

extension FriendInvitation {
    enum Status: String, Codable {
        case pending, accepted, rejected
    }
}
