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
            .post("login", use: login)
            
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
        
        var avatar: String?
        if let avatarFile = create.avatar {
            let imageType = avatarFile.filename.split(separator: ".")
            avatar = "avatar/\(id.uuidString.lowercased()).\(imageType.last ?? "")"
            do {
                req.logger.log(level: .critical, "Writing image into \(avatar!)")
                try await req.fileio.writeFile(avatarFile.data, at: "\(req.application.directory.publicDirectory)\(avatar!)")
            } catch(let err) {
                req.logger.error("\(err)")
                throw Abort(.badRequest, reason: "\(err)")
            }
        }
        
        do {
            guard let baseURL = Environment.get("BASE_URL")
            else {
                throw Abort(.internalServerError, reason: "Base URL not found.")
            }
            
            let user = try User(
                id: id,
                account: create.account,
                hashedPassword: Bcrypt.hash(create.password),
                mail: create.mail,
                name: create.name,
                birthString: create.birth,
                avatar: avatar != nil ? URL(string: baseURL + avatar!) : nil
            )
            try await user.save(on: req.db)
        } catch(let err) {
            req.logger.error("\(err)")
            throw Abort(.badRequest, reason: "\(err)")
        }
        
        return Response(status: .created, body: "Account create successfully.")
    }
}
