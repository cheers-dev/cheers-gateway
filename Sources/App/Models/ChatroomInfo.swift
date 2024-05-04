//
//  File.swift
//  
//
//  Created by Dong on 2024/5/4.
//

import Vapor

struct ChatroomInfo: Content {
    
    var chatroom: Chatroom
    var lastMessage: Message?
}
