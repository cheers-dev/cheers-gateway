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
