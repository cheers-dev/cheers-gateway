//
//  Chatroom+Info.swift
//  cheers-gateway
//
//  Created by Dong on 9/18/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Vapor

extension Chatroom {
    struct Info: Content {
        let chatroom: Chatroom
        let lastMessage: Message?
    }
}
