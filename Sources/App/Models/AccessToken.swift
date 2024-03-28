//
//  AccessToken.swift
//
//
//  Created by Dong on 2024/3/28.
//

import Fluent
import Vapor

final class AccessToken: Model, Content {
    static let schema = "access_token"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "token")
    var token: String
    
    init() {}
    
    init(id: UUID? = nil, token: String, userId: User.IDValue) {
        self.id = id
        self.token = token
        self.$user.id = userId
    }
}
