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
        
        user.post("register", use: create)
    }
    
    func create(req: Request) async throws -> User {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        
        guard create.password == create.confirmPassword
        else {
            throw Abort(.badRequest, reason: "Password not matched.")
        }
        
        let user = try User(
            account: create.account,
            hashedPassword: Bcrypt.hash(create.password),
            mail: create.mail,
            name: create.name,
            birth: create.birth,
            avatar: create.avatar
        )
        
        try await user.save(on: req.db)
        return user
    }
}
