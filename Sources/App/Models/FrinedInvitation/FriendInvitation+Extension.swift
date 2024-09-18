//
//  FriendInvitation+Extension.swift
//  cheers-gateway
//
//  Created by Dong on 9/16/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

extension FriendInvitation {
    static func getAllPendingInvitationsByUserId(_ req: Request, userId: UUID) async throws -> [FriendInvitation.Get] {
        let invitations = try await FriendInvitation
            .query(on: req.db(.psql))
            .filter(\.$addressee.$id == userId)
            .filter(\.$status == .pending)
            .with(\.$requestor)
            .all()

        return try invitations.map {
            try FriendInvitation.Get(
                id: $0.requireID(),
                requestor: User.Get(
                    id: $0.requestor.requireID(),
                    account: $0.requestor.account,
                    mail: $0.requestor.mail,
                    name: $0.requestor.name,
                    avatar: $0.requestor.avatar
                ),
                status: $0.status
            )
        }
    }

    static func getAndValidateUserInPendingInvitation(
        _ req: Request,
        invitationId: UUID,
        user: User
    ) async throws -> FriendInvitation {
        guard let invitation = try await FriendInvitation
            .query(on: req.db(.psql))
            .with(\.$requestor)
            .with(\.$addressee)
            .filter(\.$id == invitationId)
            .filter(\.$addressee.$id == user.requireID())
            .filter(\.$status == .pending)
            .first()
        else { throw Abort(.forbidden) }

        return invitation
    }

    static func getInvitationBetweenUsers(
        _ req: Request,
        requestor: User,
        addressee: User
    ) async throws -> FriendInvitation? {
        try await FriendInvitation
            .query(on: req.db(.psql))
            .with(\.$requestor)
            .with(\.$addressee)
            .group(.or) { try $0
                .group { try $0
                    .filter(\.$requestor.$id == requestor.requireID())
                    .filter(\.$addressee.$id == addressee.requireID())
                }
                .group { try $0
                    .filter(\.$requestor.$id == addressee.requireID())
                    .filter(\.$addressee.$id == requestor.requireID())
                }
            }.first()
    }
}
