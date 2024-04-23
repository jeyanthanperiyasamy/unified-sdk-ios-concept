//
//  User.swift
//  PingOidc
//
//  Created by jey periyasamy on 4/23/24.
//

protocol User {
    
    func accessToken() async -> Result<AccessToken, Error>

    func revoke() async

    func userinfo(cache: Bool) async -> String

    func logout() async -> String
}

