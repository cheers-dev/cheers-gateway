//
//  UserInInvitation.swift
//  
//
//  Created by Dong on 2024/7/21.
//

import Fluent
import Vapor

struct UserInInvitation {
    static func validation(_ req: Request) async throws -> FriendInvitation {
        let user = try req.auth.require(User.self)
        
        guard let requestId = try? req.query.get<String>(String.self, at: "id"),
              let requestUuid = UUID(uuidString: requestId)
        else { throw Abort(.badRequest) }
        
        guard let invitation = try await FriendInvitation.query(on: req.db(.psql))
                    .filter(\.$id == requestUuid)
                    .filter(\.$addressee.$id == user.id!)
                    .first(),
              invitation.status == .pending
        else { throw Abort(.forbidden) }
        
        return invitation
    }
}
