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
    @Field(key: "birth")
    var birth: Date?
    
    @Field(key: "avatar")
    var avatar: URL?
    
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


extension User {
    struct Create: Content {
        var account: String
        var password: String
        var confirmPassword: String
        var mail: String
        var name: String
        var birth: Date?
        var avatar: URL?
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("account", as: String.self, is: !.empty, required: true)
        validations.add("mail", as: String.self, is: .email, required: true)
        validations.add("password", as: String.self, is: .count(8...), required: true)
        validations.add("birth", as: Date.self, is: .valid, required: false)
        validations.add("avatar", as: URL.self, is: .valid, required: false)
    }
}
