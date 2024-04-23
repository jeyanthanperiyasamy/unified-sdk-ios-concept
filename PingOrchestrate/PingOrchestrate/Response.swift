//
//  SampleRequest.swift
//  PingOrchestrate
//
//  Created by jey periyasamy on 4/24/24.
//

struct Response {
    let data: Data
    let response: URLResponse
    
    func body() async throws -> String {
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func status() -> Int {
        return (response as? HTTPURLResponse)?.statusCode ?? 0
    }
    
    func cookies() -> [String] {
        return (response as? HTTPURLResponse)?.allHeaderFields["Set-Cookie"] as? [String] ?? []
    }
    
    func header(name: String) -> String? {
        return (response as? HTTPURLResponse)?.allHeaderFields[name] as? String
    }
}
