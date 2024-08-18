//
//  FriendValidation.swift
//
//
//  Created by Dong on 2024/7/28.
//

import Fluent
import Vapor

struct FriendValidation {
    static func validation(
        req: Request,
        user: User,
        with friend: UUID
    ) async throws -> Bool {
        let friend = try await Friend
            .query(on: req.db(.psql))
            .group(.or) {
                try $0.group(.and) {
                    try $0.filter(\.$uid1.$id == user.requireID())
                    $0.filter(\.$uid2.$id == friend)
                }
                try $0.group(.and) {
                    try $0.filter(\.$uid2.$id == user.requireID())
                    $0.filter(\.$uid1.$id == friend)
                }
            }
            .first()
        
        return friend != nil
    }
}
