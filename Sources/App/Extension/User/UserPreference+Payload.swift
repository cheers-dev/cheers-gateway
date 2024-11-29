//
//  UserPreference.swift
//  cheers-gateway
//
//  Created by Dong on 11/14/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Vapor

// MARK: - UserPreference.Payload

extension UserPreference {
    struct Payload: Codable {
        let rankings: [Ranking]
    }

    struct Ranking: Codable {
        let food: Category
        let score: Int
    }

    static func toUserPreferenceModel(
        _ payload: [Ranking],
        userId: UUID
    ) throws -> UserPreference {
        let duplicates = Dictionary(grouping: payload, by: { $0.food })
            .filter { $1.count > 1 }
            .keys
        
        guard duplicates.isEmpty else {
            throw Abort(.badRequest, reason: "Duplicate food categories found: \(duplicates)")
        }

        var preferences = [UserPreference.Category: Int]()
        
        for preference in payload {
            preferences[preference.food] = preference.score
        }
        
        return UserPreference(userId: userId, preferences: preferences)
    }

    func updatingFromPayload(payload: [UserPreference.Ranking]) {
        var preferences = [UserPreference.Category: Int]()

        for preference in payload {
            preferences[preference.food] = preference.score
        }

        self.createOrUpdateModel(preferences: preferences)
    }
}
