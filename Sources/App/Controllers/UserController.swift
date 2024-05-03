//
//  UserController.swift
//  
//
//  Created by Dong on 2024/3/27.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let user = routes.grouped("user")
        
        user
            .grouped(User.authenticator())
            .on(.GET, "login", body: .collect(maxSize: "500kb"), use: login)
            
        user.on(.POST, "register", body: .collect(maxSize: "1mb"), use: register)
    }
    
    func login(req: Request) async throws -> String {
        let user = try req.auth.require(User.self)
        
        var token = try await AccessToken
            .query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .first()
        
        if token == nil {
            token = try user.generateAccessToken()
        }
        
        try await token!.save(on: req.db)
        return token!.token
    }
    
    func register(req: Request) async throws -> Response {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        
        let id = UUID()
        let token: AccessToken
        
        do {
            let user = try User(
                id: id,
                account: create.account,
                hashedPassword: Bcrypt.hash(create.password),
                mail: create.mail,
                name: create.name,
                birthString: create.birth
            )
            try await user.save(on: req.db)
            token = try user.generateAccessToken()
            try await token.save(on: req.db)
        } catch(let err) {
            req.logger.error("\(String(reflecting: err))")
            throw Abort(.badRequest, reason: "\(err)")
        }
        
        return Response(status: .created, body: .init(string: token.token))
    }
}
