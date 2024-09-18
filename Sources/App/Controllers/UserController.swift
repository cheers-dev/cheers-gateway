//
//  UserController.swift
//  cheers-gateway
//
//  Created by Dong on 3/27/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

// MARK: - UserController

struct UserController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let user = routes.grouped("user")
        
        user.grouped(User.authenticator())
            .on(.GET, "login", body: .collect(maxSize: "500kb"), use: login)
            
        user.on(.POST, "register", body: .collect(maxSize: "1mb"), use: register)
    }
}

extension UserController {
    private func login(req: Request) async throws -> User.LoginResponse {
        let user = try req.auth.require(User.self)
        
        var token = try await AccessToken
            .query(on: req.db(.psql))
            .filter(\.$user.$id == user.id!)
            .first()
        
        if token == nil {
            token = try user.generateAccessToken()
        }
        
        try await token!.save(on: req.db(.psql))
        return User.LoginResponse(accessToken: token!.token, userId: user.id!)
    }
    
    private func register(req: Request) async throws -> Response {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        
        let token: AccessToken
        let userId = UUID()
        
        do {
            let user = try User(
                id: userId,
                account: create.account,
                hashedPassword: Bcrypt.hash(create.password),
                mail: create.mail,
                name: create.name,
                birthString: create.birth
            )
            
            try await user.save(on: req.db(.psql))
            token = try user.generateAccessToken()
            try await token.save(on: req.db(.psql))
        } catch let err {
            req.logger.error("\(String(reflecting: err))")
            throw Abort(.badRequest, reason: "\(err)")
        }
        
        let loginResponse = User.LoginResponse(accessToken: token.token, userId: userId)
        guard let loginResponseData = try? JSONEncoder().encode(loginResponse)
        else { throw Abort(.internalServerError) }
        
        return Response(status: .created, body: .init(data: loginResponseData))
    }
}
