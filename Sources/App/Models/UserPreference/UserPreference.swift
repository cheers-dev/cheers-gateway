//
//  UserPreference.swift
//
//
//  Created by 楊晏禎 on 2024/10/24.
//

import Fluent
import Vapor

struct RankingPayload: Content {
    let userId: String
    let rankings: [RankingEntry]
}

struct RankingEntry: Content {
    let food: String
    let score: Int
}

final class UserPreference: Model, Content, @unchecked Sendable {
    static let schema = "user_preference"

    @ID(custom: "user_id", generatedBy: .user)
    var id: UUID?
    
    @Field(key: "美式")
    var american: Int

    @Field(key: "中式")
    var chinese: Int

    @Field(key: "甜點")
    var dessert: Int

    @Field(key: "日式")
    var japanese: Int

    @Field(key: "越式")
    var vietnamese: Int

    @Field(key: "義式")
    var italian: Int

    @Field(key: "韓式")
    var korean: Int

    @Field(key: "港式")
    var hongkong: Int

    @Field(key: "泰式")
    var thai: Int

    @Field(key: "法式")
    var french: Int

    @Field(key: "西式")
    var western: Int

    @Field(key: "東南亞")
    var southeastAsian: Int

    @Field(key: "異國料理")
    var exotic: Int

    @Field(key: "酒吧")
    var bar: Int

    init() {}

    init(userId: UUID, rankings: [RankingEntry]) {
        self.id = userId
        self.american = rankings.first(where: { $0.food == "美式" })?.score ?? 0
        self.chinese = rankings.first(where: { $0.food == "中式" })?.score ?? 0
        self.dessert = rankings.first(where: { $0.food == "甜點" })?.score ?? 0
        self.japanese = rankings.first(where: { $0.food == "日式" })?.score ?? 0
        self.vietnamese = rankings.first(where: { $0.food == "越式" })?.score ?? 0
        self.italian = rankings.first(where: { $0.food == "義式" })?.score ?? 0
        self.korean = rankings.first(where: { $0.food == "韓式" })?.score ?? 0
        self.hongkong = rankings.first(where: { $0.food == "港式" })?.score ?? 0
        self.thai = rankings.first(where: { $0.food == "泰式" })?.score ?? 0
        self.french = rankings.first(where: { $0.food == "法式" })?.score ?? 0
        self.western = rankings.first(where: { $0.food == "西式" })?.score ?? 0
        self.southeastAsian = rankings.first(where: { $0.food == "東南亞" })?.score ?? 0
        self.exotic = rankings.first(where: { $0.food == "異國料理" })?.score ?? 0
        self.bar = rankings.first(where: { $0.food == "酒吧" })?.score ?? 0
    }
}
