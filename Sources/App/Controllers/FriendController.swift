//
//  FriendController.swift
//
//
//  Created by Dong on 2024/6/25.
//

import Fluent
import Foundation
import Vapor

// MARK: - FriendController

struct FriendController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let friend = routes
            .grouped("friend")
            .grouped(AccessToken.authenticator())
        
        friend.on(.POST, "sendInvite", use: sendInvite)
        friend.on(.PATCH, "accept", use: acceptInvitation)
        friend.on(.PATCH, "reject", use: rejectInvitation)
        friend.on(.GET, "getInvites", use: getPendingInvitations)
        friend.on(.GET, "getFriends", use: getFriendList)
    }
}
    
extension FriendController {
    func sendInvite(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        let data = try req.content.decode(FriendInvitation.Create.self)
        
        guard let addressee = try await User.find(data.addressee, on: req.db(.psql))
        else { throw Abort(.badRequest) }
        
        if let invitation = try await FriendInvitation.getInvitationBetweenUsers(
            req,
            requestor: user,
            addressee: addressee
        ) { return try await handleSendInvitationWhenExist(req, invitation: invitation) }
        
        let createInvitation = try FriendInvitation(requestor: user, addressee: addressee)
        try await createInvitation.save(on: req.db(.psql))
        
        return .init(status: .ok)
    }
    
    func acceptInvitation(_ req: Request) async throws -> Response {
        let invitation = try await getAndValidateUserInPendingInvitationFromRequest(from: req)
        invitation.status = .accepted
        try await invitation.update(on: req.db(.psql))
        
        let friend = try Friend(uid1: invitation.requestor, uid2: invitation.addressee)
        try await friend.save(on: req.db(.psql))
        
        return .init(status: .ok)
    }
    
    func rejectInvitation(_ req: Request) async throws -> Response {
        let invitation = try await getAndValidateUserInPendingInvitationFromRequest(from: req)
        invitation.status = .rejected
        try await invitation.update(on: req.db(.psql))
        return .init(status: .ok)
    }
    
    func getPendingInvitations(_ req: Request) async throws -> [FriendInvitation.Get] {
        let user = try req.auth.require(User.self)
        return try await FriendInvitation.getAllPendingInvitationsByUserId(
            req,
            userId: user.requireID()
        )
    }
    
    // MARK: - Friend
    
    func getFriendList(_ req: Request) async throws -> [User.Get] {
        let user = try req.auth.require(User.self)
        return try await Friend.getFriendListFromUserId(req, userId: user.requireID())
    }
}

// MARK: - Internal func

extension FriendController {
    private func handleSendInvitationWhenExist(
        _ req: Request,
        invitation: FriendInvitation
    ) async throws -> Response {
        if invitation.status != .rejected { return .init(status: .conflict) }
        
        invitation.status = .pending
        try await invitation.update(on: req.db(.psql))
        return .init(status: .ok)
    }
    
    private func getAndValidateUserInPendingInvitationFromRequest(
        from req: Request
    ) async throws -> FriendInvitation {
        let user = try req.auth.require(User.self)
        let invitationUUID = try getValidRequestIdFromBody(from: req)
        return try await FriendInvitation.getAndValidateUserInPendingInvitation(
            req,
            invitationId: invitationUUID,
            user: user
        )
    }

    private func getValidRequestIdFromBody(from req: Request) throws -> UUID {
        guard let requestId = try? req.query.get<String>(String.self, at: "id"),
              let requestUUID = UUID(uuidString: requestId)
        else { throw Abort(.badRequest) }
        
        return requestUUID
    }
}
