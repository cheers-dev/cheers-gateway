//
//  Message+Get.swift
//  cheers-gateway
//
//  Created by Dong on 12/2/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Foundation
import Vapor

extension Message {
    struct Get: Codable, Content {
        let id: UUID
        let user: User.Get
        let content: String
        let createdAt: Date
    }
}
