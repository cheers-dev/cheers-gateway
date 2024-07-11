//
//  FriendController.swift
//
//
//  Created by Dong on 2024/6/25.
//

import Fluent
import Foundation
import Vapor

struct FriendController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let friend = routes.grouped("friend")
        
        friend
            .grouped(AccessToken.authenticator())
            .on(.POST, "sendInvite", use: sendInvite)
    }

    func sendInvite(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        let data = try req.content.decode(Friend.Create.self)
        
        guard let addressee = try await User.query(on: req.db(.psql))
            .filter(\.$id == data.addressee)
            .first()
        else { return .init(status: .badRequest) }
        
        let invitation = try await FriendInvitation
            .query(on: req.db(.psql))
            .group(.or) { group in
                group
                    .group { asRequestor in
                        asRequestor
                            .filter(\.$requestor.$id == user.id!)
                            .filter(\.$addressee.$id == addressee.id!)
                    }
                    .group { asAddressee in
                        asAddressee
                            .filter(\.$requestor.$id == addressee.id!)
                            .filter(\.$addressee.$id == user.id!)
                    }
            }.first()
        
        if invitation != nil {
            if invitation!.status == .rejected {
                invitation!.status = .pending
                try await invitation!.update(on: req.db(.psql))
                
                return .init(status: .ok)
            }
            
            return .init(status: .conflict)
        }
        
        let createInvitation = try FriendInvitation(
            requestor: user,
            addressee: addressee
        )
        try await createInvitation.save(on: req.db(.psql))
        
        return .init(status: .ok)
    }
}
