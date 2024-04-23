////
////  OIDCUser.swift
////  PingOidc
////
////  Created by jey periyasamy on 4/24/24.
////
//
//import Foundation
//
//// Define OidcUser class conforming to User protocol
//class OidcUser: User {
//    
//    let config: OidcClientConfig
//    private var userinfo: String?
//    private let oidcClient: OidcClient
//    
//    init(config: OidcClientConfig) {
//        self.config = config
//        self.oidcClient = OidcClient(config: config)
//    }
//    
//    func accessToken() async throws -> Result<AccessToken, Error> {
//        return try await oidcClient.accessToken()
//    }
//    
//    func revoke() async throws {
//        try await oidcClient.revoke()
//    }
//    
//    func userinfo(cache: Bool) async throws -> String {
//        if let cachedUserinfo = userinfo, cache {
//            return cachedUserinfo
//        } else {
//            let userinfo = try await oidcClient.userinfo()
//            self.userinfo = cache ? userinfo : nil
//            return userinfo
//        }
//    }
//    
//    func logout() async {
//        await oidcClient.endSession()
//    }
//}
