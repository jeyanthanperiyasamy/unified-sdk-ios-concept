//
//  SampleRequest.swift
//  PingOrchestrate
//
//  Created by jey periyasamy on 4/24/24.
//

import Foundation

import UIKit

public struct Cookies {
    // Define your Cookies structure as needed
    // You can use a dictionary to hold cookie key-value pairs
    // For example:
    public var cookies: [String: String] = [:]
}

public class Request {
    var urlRequest: URLRequest
    
    public init() {
        self.urlRequest = URLRequest(url: URL(string: "https://google.com")!) // Initialize with a default URL
    }
    
    public func url(_ urlString: String) {
        if let url = URL(string: urlString) {
            self.urlRequest = URLRequest(url: url)
        }
    }
    
    public func parameter(name: String, value: String) {
        if var components = URLComponents(url: self.urlRequest.url!, resolvingAgainstBaseURL: false) {
            if components.queryItems == nil {
                components.queryItems = []
            }
            components.queryItems?.append(URLQueryItem(name: name, value: value))
            if let updatedURL = components.url {
                self.urlRequest.url = updatedURL
            }
        }
    }
    
    public func header(name: String, value: String) {
        self.urlRequest.addValue(value, forHTTPHeaderField: name)
    }
    
    public func cookies(cookies: Cookies) {
        for (name, value) in cookies.cookies {
            let cookieString = "\(name)=\(value)"
            self.urlRequest.addValue(cookieString, forHTTPHeaderField: "Cookie")
        }
    }
    
    public func body(body: [String: Any]) {
        do {
            self.urlRequest.httpMethod = "POST"
            self.urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            self.urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error encoding JSON: \(error)")
        }
    }
    
    public func form(formData: [String: String]) {
        var formString = ""
        for (key, value) in formData {
            formString += "\(key)=\(value)&"
        }
        formString.removeLast() // Remove the last '&' character
        
        self.urlRequest.httpMethod = "POST"
        self.urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.urlRequest.httpBody = formString.data(using: .utf8)
    }
}

