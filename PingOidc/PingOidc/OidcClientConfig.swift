//
//  OidcClientConfig.swift
//  PingOidc
//
//  Created by jey periyasamy on 4/23/24.
//

import Foundation

class OidcClientConfig {
    var openId: OpenIdConfiguration?
    var agent: AgentDelegate<Any>?
    var logger = Logger()
    var storage: String? = ""

    var discoveryEndpoint = ""
    var clientId = ""
    var scopes = Set<String>()
    var redirectUri = ""
    var loginHint: String?
    var nonce: String?
    var display: String?
    var prompt: String?
    var uiLocales: String?
    var acrValues: String?
    var additionalParameters = [String: String]()

    func scope(_ scope: String) {
        scopes.insert(scope)
    }

    func initialize() async throws {
        guard openId == nil else {
            return
        }

        guard let url = URL(string: discoveryEndpoint) else {
            throw OidcError.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OidcError.invalidResponse
        }

        do {
            let configuration = try JSONDecoder().decode(OpenIdConfiguration.self, from: data)
            openId = configuration
        }
        catch {
            throw OidcError.invalidData
        }
    }

    func clone() -> OidcClientConfig {
        let cloned = OidcClientConfig()
        cloned.update(with: self)
        return cloned
    }

    func update(with other: OidcClientConfig) {
        self.openId = other.openId
        self.agent = other.agent
        self.logger = other.logger
        self.storage = other.storage
        self.discoveryEndpoint = other.discoveryEndpoint
        self.clientId = other.clientId
        self.scopes = other.scopes
        self.redirectUri = other.redirectUri
        self.loginHint = other.loginHint
        self.nonce = other.nonce
        self.display = other.display
        self.prompt = other.prompt
        self.uiLocales = other.uiLocales
        self.acrValues = other.acrValues
        self.additionalParameters = other.additionalParameters
    }
}

enum OidcError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
    case tokenRetrievalFailed
}


struct OpenIdConfiguration: Codable {
    // Define properties corresponding to the serialized names
    let authorizationEndpoint: String
    let tokenEndpoint: String
    let userinfoEndpoint: String
    let endSessionEndpoint: String
    let revocationEndpoint: String

    // Define CodingKeys enum to map serialized names to property names
    private enum CodingKeys: String, CodingKey {
        case authorizationEndpoint = "authorization_endpoint"
        case tokenEndpoint = "token_endpoint"
        case userinfoEndpoint = "userinfo_endpoint"
        case endSessionEndpoint = "end_session_endpoint"
        case revocationEndpoint = "revocation_endpoint"
    }
}

class Logger {
    func log(_ message: String) {
        print("Log: \(message)")
    }
}

class MemoryStorage<T> {
    // Define your MemoryStorage implementation here
}
