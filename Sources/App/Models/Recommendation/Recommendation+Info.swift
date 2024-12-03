//
//  Recommendation+Info.swift
//
//
//  Created by Tintin on 2024/10/22.
//

import Vapor

extension Recommendation {
    struct Info: Content {
        let chatroom: Chatroom
        let lastRecommend: Date?
    }
}