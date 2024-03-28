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
            
        user.post("register", use: register)
    }
    
    func register(req: Request) async throws -> Response {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        
        guard create.password == create.confirmPassword
        else {
            throw Abort(.badRequest, reason: "Password not matched.")
        }
        
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
            let user = try User(
                id: id,
                account: create.account,
                hashedPassword: Bcrypt.hash(create.password),
                mail: create.mail,
                name: create.name,
                birth: create.birth,
                avatar: avatar != nil ? URL(string: "http://localhost:8080/\(avatar!)") : nil
            )
            try await user.save(on: req.db)
        } catch(let err) {
            req.logger.error("\(err)")
            throw Abort(.badRequest, reason: "\(err)")
        }
        
        return Response(status: .created, body: "Account create successfully.")
    }
}
