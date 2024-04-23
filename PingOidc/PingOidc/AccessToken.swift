//
//  AccessToken.swift
//  FRAuth
//
//  Copyright (c) 2024 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation

struct AccessToken: Codable {
    let value: String
    let tokenType: String?
    let scope: String?
    let expiresIn: Int
    let refreshToken: String?
    let idToken: String?
    let expireAt: Int

    var isExpired: Bool {
        let currentEpochSeconds = Int(Date().timeIntervalSince1970)
        return currentEpochSeconds >= expireAt
    }

    // Custom decoding initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType)
        scope = try container.decodeIfPresent(String.self, forKey: .scope)
        expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        idToken = try container.decodeIfPresent(String.self, forKey: .idToken)
        expireAt = try container.decode(Int.self, forKey: .expireAt)
    }

    // Custom encoding method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encodeIfPresent(tokenType, forKey: .tokenType)
        try container.encodeIfPresent(scope, forKey: .scope)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encodeIfPresent(refreshToken, forKey: .refreshToken)
        try container.encodeIfPresent(idToken, forKey: .idToken)
        try container.encode(expireAt, forKey: .expireAt)
    }
}

// Define CodingKeys for the AccessToken struct
extension AccessToken {
    enum CodingKeys: String, CodingKey {
        case value = "access_token"
        case tokenType = "token_type"
        case scope
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case expireAt
    }
}
