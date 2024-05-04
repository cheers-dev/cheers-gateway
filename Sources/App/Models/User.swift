//
//  User.swift
//
//
//  Created by Dong on 2024/3/27.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "user"
    
    // required values
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "account")
    var account: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "mail")
    var mail: String
    
    @Field(key: "name")
    var name: String
    
    // optional values
    @OptionalField(key: "birth")
    var birth: Date?
    
    @OptionalField(key: "avatar")
    var avatar: URL?
    
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    
    @Siblings(through: ChatroomParticipant.self, from: \.$user, to: \.$chatroom)
    var chatrooms: [Chatroom]
    
    init() {}
    
    init(id: UUID? = nil, account: String, hashedPassword: String, mail: String, name: String, birthString: String, avatar: URL? = nil) throws {
        self.id = id
        self.account = account
        self.password = hashedPassword
        self.mail = mail
        self.name = name
        self.avatar = avatar
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .gmt
        
        guard let birth = dateFormatter.date(from: birthString)
        else {
            throw Abort(.badRequest, reason: "Invalid date format.")
        }
        
        self.birth = birth
    }
}
