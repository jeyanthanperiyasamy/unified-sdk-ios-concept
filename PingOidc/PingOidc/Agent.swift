//
//  Agent.swift
//  PingOidc
//
//  Created by jey periyasamy on 4/23/24.
//

import Foundation


// Protocol defining Agent behavior
protocol Agent {
    func endSession(oidcConfig: AnyOidcConfig, idToken: String) async throws -> Bool
       
    func authenticate(oidcConfig: AnyOidcConfig) async throws -> AuthCode
}

// Type-erased wrapper for OIDC configuration
class AnyOidcConfig {
    let oidcClientConfig: OidcClientConfig
    private let _config: () -> Any
    
    init<Config>(config: Config, oidcClientConfig: OidcClientConfig) {
        self._config = { config }
        self.oidcClientConfig = oidcClientConfig
    }
    
    func getConfig<Config>() -> Config {
        return _config() as! Config
    }
}


class OidcConfig<T> {
    let config: T
    let oidcClientConfig: OidcClientConfig
    
    init(config: T, oidcClientConfig: OidcClientConfig) {
        self.config = config
        self.oidcClientConfig = oidcClientConfig
    }
}

// Delegate class to dispatch Agent functions
class AgentDelegate<T>  {
    let agent: any Agent
    let oidcConfig: AnyOidcConfig
        
    init<Config>(agent: any Agent, agentConfig: Config, oidcClientConfig: OidcClientConfig) {
            self.agent = agent
            self.oidcConfig = AnyOidcConfig(config: agentConfig, oidcClientConfig: oidcClientConfig)
        }
        
        func authenticate() async throws -> AuthCode {
            return try await agent.authenticate(oidcConfig: oidcConfig)
        }
        
        func endSession(idToken: String) async throws -> Bool {
            return try await agent.endSession(oidcConfig: oidcConfig, idToken: idToken)
        }
}

struct AuthCode: Codable {
    let code: String
    let state: String?
    let codeVerifier: String?

    // Optional initializer to provide default values
    init(code: String = "", state: String? = nil, codeVerifier: String? = nil) {
        self.code = code
        self.state = state
        self.codeVerifier = codeVerifier
    }

    // Codable protocol implementation for serialization/deserialization
    private enum CodingKeys: String, CodingKey {
        case code
        case state
        case codeVerifier
    }
}
