//
//  Create.swift
//
//
//  Created by Dong on 2024/3/28.
//

import Fluent
import Vapor

extension User {
    struct Create: Content {
        var account: String
        var password: String
        var confirmPassword: String
        var mail: String
        var name: String
        var birth: Date?
        var avatar: File?
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("account", as: String.self, is: !.empty, required: true)
        validations.add("mail", as: String.self, is: .email, required: true)
        validations.add("password", as: String.self, is: !.empty, required: true)
        validations.add("name", as: String.self, is: !.empty, required: true)
    }
}
