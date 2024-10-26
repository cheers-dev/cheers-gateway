//
//  UserPreferenceController.swift
//
//
//  Created by 楊晏禎 on 2024/10/24.
//

import Vapor
import Fluent

struct UserPreferenceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let rankings = routes.grouped("user", "rankings")
        rankings.post(use: createRanking)
    }

    func createRanking(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let rankingPayload = try req.content.decode(RankingPayload.self)
        
        guard let userId = UUID(uuidString: rankingPayload.userId) else {
            throw Abort(.badRequest, reason: "Invalid userId")
        }

        return UserPreference.query(on: req.db)
            .filter(\.$id == userId)
            .first()
            .flatMap { existingPreference in
                let rankingData: UserPreference

                if let existingPreference = existingPreference {
                    existingPreference.updateScores(from: rankingPayload.rankings)
                    rankingData = existingPreference
                } else {
                    rankingData = UserPreference(userId: userId, rankings: rankingPayload.rankings)
                }

                return rankingData.save(on: req.db).map {
                    return .created
                }
            }
    }
}

extension UserPreference {
    func updateScores(from rankings: [RankingEntry]) {
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
