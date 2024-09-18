//
//  Friend+Extension.swift
//  cheers-gateway
//
//  Created by Dong on 9/17/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

extension Friend {
    static func getFriendListFromUserId(_ req: Request, userId: UUID) async throws -> [User.Get] {
        let friendList = try await Friend.query(on: req.db(.psql))
            .with(\.$uid1)
            .with(\.$uid2)
            .group(.or) { $0
                .filter(\.$uid1.$id == userId)
                .filter(\.$uid2.$id == userId)
            }.all()

        return try friendList.map {
            var friend: User
            if try $0.uid1.requireID() == userId { friend = $0.uid2 }
            else { friend = $0.uid1 }

            return try User.Get(
                id: friend.requireID(),
                account: friend.account,
                mail: friend.mail,
                name: friend.name,
                avatar: friend.avatar
            )
        }
    }

    static func verifyFriend(
        _ req: Request,
        between user1: User,
        and user2ID: UUID
    ) async throws -> Bool {
        let friend = try await Friend
            .query(on: req.db(.psql))
            .group(.or) { try $0
                .group(.and) { try $0
                    .filter(\.$uid1.$id == user1.requireID())
                    .filter(\.$uid2.$id == user2ID)
                }
                .group(.and) { try $0
                    .filter(\.$uid2.$id == user1.requireID())
                    .filter(\.$uid1.$id == user2ID)
                }
            }.first()

        return friend != nil
    }
}
