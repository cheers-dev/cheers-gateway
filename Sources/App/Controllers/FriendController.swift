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
        return .init(status: .ok)
    }
}
