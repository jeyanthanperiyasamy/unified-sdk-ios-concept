////
////  OIDCClient.swift
////  PingOidc
////
////  Created by jey periyasamy on 4/24/24.
////
//
//import Foundation
//
//class OidcClient {
//    let config: OidcClientConfig
//      
//      init(config: OidcClientConfig) {
//          self.config = config
//      }
//    
//    func accessToken() async throws -> AccessToken {
//          try await refreshTokenIfNeeded()
//      }
//      
//      private func refreshTokenIfNeeded() async throws -> AccessToken {
//          guard let cachedToken = config.storage.get(), !cachedToken.isExpired else {
//              throw OidcError.tokenRetrievalFailed
//          }
//          
//          do {
//              return try await refreshAccessToken(refreshToken: cachedToken.refreshToken ?? "")
//          } catch {
//              throw OidcError.tokenRefreshFailed
//          }
//      }
//      
//    
//}
