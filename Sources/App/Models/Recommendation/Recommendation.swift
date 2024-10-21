//
//  Recommendation.swift
//
//
//  Created by Tintin on 2024/10/21.
//

import Fluent
import MongoKitten
import Vapor

final class Recommendation: Model, Content, @unchecked Sendable {
    static let schema = "recommendation"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "chatroomId")
    var chatroomId: UUID
        
    @Field(key: "recommendation")
    var recommendation: [RestaurantRecommendation]
    
    @Field(key: "updatedAt")
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, chatroomId: UUID, recommendation: [RestaurantRecommendation], updatedAt: Date) {
        self.id = id
        self.chatroomId = chatroomId
        self.recommendation = recommendation
        self.updatedAt = updatedAt
    }
}

// RestaurantRecommendation structure
struct RestaurantRecommendation: Content {
    var opening_time: String
    var name: String
    var category: String
    var rating: Double
    var address: String
    var phone: String
    var price: String
//    var likes: [Like]
}