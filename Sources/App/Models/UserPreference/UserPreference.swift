//
//  UserPreference.swift
//
//
//  Created by 楊晏禎 on 2024/10/24.
//

import Fluent
import Vapor

// MARK: - RankingPayload

struct RankingPayload: Content {
    let userId: String
    let rankings: [RankingEntry]
}

// MARK: - RankingEntry

struct RankingEntry: Content {
    let food: String
    let score: Int
}

// MARK: - UserPreference

final class UserPreference: Model, Content, @unchecked Sendable {
    static let schema = "user_preference"
    
    enum Category: String, Codable, CaseIterable {
        case american, chinese, dessert, japanese, vietnamese, italian, korean, hongkong, thai, french, western, southeastAsian, exotic, bar
    }
    
    @ID(custom: "user_id", generatedBy: .user)
    var id: UUID?
    
    @Field(key: "american")
    var american: Int
    
    @Field(key: "chinese")
    var chinese: Int
    
    @Field(key: "dessert")
    var dessert: Int
    
    @Field(key: "japanese")
    var japanese: Int
    
    @Field(key: "vietnamese")
    var vietnamese: Int
    
    @Field(key: "italian")
    var italian: Int
    
    @Field(key: "korean")
    var korean: Int
    
    @Field(key: "hongkong")
    var hongkong: Int
    
    @Field(key: "thai")
    var thai: Int
    
    @Field(key: "french")
    var french: Int
    
    @Field(key: "western")
    var western: Int
    
    @Field(key: "southeastAsian")
    var southeastAsian: Int
    
    @Field(key: "exotic")
    var exotic: Int
    
    @Field(key: "bar")
    var bar: Int
    
    init() {}
    
    init(userId: UUID, preferences: [UserPreference.Category: Int]) {
        self.id = userId
        self.createOrUpdateModel(preferences: preferences)
    }
    
    func createOrUpdateModel(preferences: [UserPreference.Category: Int]) {
        for category in Category.allCases {
            let value = preferences[category] ?? 0
            switch category {
                case .american: self.american = value
                case .chinese: self.chinese = value
                case .dessert: self.dessert = value
                case .japanese: self.japanese = value
                case .vietnamese: self.vietnamese = value
                case .italian: self.italian = value
                case .korean: self.korean = value
                case .hongkong: self.hongkong = value
                case .thai: self.thai = value
                case .french: self.french = value
                case .western: self.western = value
                case .southeastAsian: self.southeastAsian = value
                case .exotic: self.exotic = value
                case .bar: self.bar = value
            }
        }
    }
    
    
}
