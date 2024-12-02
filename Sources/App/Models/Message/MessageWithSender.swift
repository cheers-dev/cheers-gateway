//
//  MessageWithSender.swift
//
//
//  Created by Tintin on 2024/9/22.
//

import Fluent
import Vapor

struct MessageWithSender: Content, @unchecked Sendable{
    let id: UUID
    let userId: UUID
    let chatroomId: UUID
    let content: String
    let createdAt: Date?
    let name: String?
//    let avatar: URL?
}
