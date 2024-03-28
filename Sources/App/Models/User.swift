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
    
    @Field(key: "hashed_password")
    var hashedPassword: String
    
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
    
    init() {}
    
    init(id: UUID? = nil, account: String, hashedPassword: String, mail: String, name: String, birth: Date? = nil, avatar: URL? = nil) {
        self.id = id
        self.account = account
        self.hashedPassword = hashedPassword
        self.mail = mail
        self.name = name
        self.birth = birth
        self.avatar = avatar
    }
}
