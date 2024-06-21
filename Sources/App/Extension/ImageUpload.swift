//
//  ImageUpload.swift
//
//
//  Created by Dong on 2024/6/21.
//

import Fluent
import Vapor

struct ImageUpload: Content {
    var image: File
}

extension ImageUpload: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("image", as: File.self, required: true)
    }
    
    enum Path: String {
        case avatar, chat, restaurant, system
    }
}
