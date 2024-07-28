//
//  FriendInvitationGet.swift
//
//
//  Created by Dong on 2024/7/21.
//

import Fluent
import Vapor

extension FriendInvitation {
    struct Get: Content {
        let id: UUID
        let requestor: User.Get
        let status: FriendInvitation.Status
    }
}
