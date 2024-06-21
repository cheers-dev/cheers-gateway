//
//  ImageController.swift
//
//
//  Created by Dong on 2024/6/21.
//

import Vapor

struct ImageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let imageRoutes = routes.grouped("images")
        
        imageRoutes
            .grouped(AccessToken.authenticator())
            .on(
                .POST,
                "upload", ":path",
                body: .collect(maxSize: "1mb"),
                use: uploadImage
            )
    }
    
    func uploadImage(req: Request) async throws -> Response {
        let data = try req.content.decode(ImageUpload.self)
        
        guard let baseURL = Environment.get("BASE_URL")
        else { throw Abort(.internalServerError) }

        guard let path = req.parameters.get("path"),
              let uploadPath = ImageUpload.Path(rawValue: path),
              let imageType = data.image.filename.split(separator: ".").last,
              ["png", "jpeg", "jpg", "gif"].contains(imageType.lowercased())
        else { throw Abort(.badRequest) }
        
        let id = UUID()
        let publicDirectory = req.application.directory.publicDirectory
        let imagePath = "\(uploadPath)/\(id.uuidString.lowercased()).\(imageType)"
        
        do {
            req.logger.log(level: .info, "Uploading image to \(imagePath)")
            try await req.fileio
                .writeFile(
                    data.image.data,
                    at: "\(publicDirectory)\(imagePath)"
                )
        } catch {
            req.logger.error("\(error)")
            throw Abort(.badRequest, reason: "\(error)")
        }
                
        return Response(
            status: .ok,
            body: .init(string: "\(baseURL)\(imagePath)")
        )
    }
}
