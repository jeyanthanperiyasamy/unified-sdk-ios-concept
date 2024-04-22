//
//  RestClient.swift
//  FRCore
//
//  Copyright (c) 2020-2023 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import UIKit

/// Completion callback for REST API result as `Result` instance
public typealias ResultCallback = (Result) -> Void

/// This class is responsible to handle REST API request, and acts as HTTP client for SDK Core
public class RestClient: NSObject {
    
    //  MARK: - Property
    
    /// Singleton instance for `RestClient`
    @objc public static let shared = RestClient()
    /// URLSession to be consumed through RestClient
    var _urlSession: URLSession?
   
    
    static var defaultURLSessionConfiguration: URLSessionConfiguration {
        get {
            let config = URLSessionConfiguration.default
            // Setting `httpCookieStorage` to nil disables cookie storage
            config.httpCookieStorage = nil
            config.httpCookieAcceptPolicy = .never
            config.httpShouldSetCookies = false
            // Setting `urlCache` to nil disables caching
            config.urlCache = nil
            return config
        }
    }
    
    /// URLSession instance variable for `RestClient`
    fileprivate var session: URLSession {
        get {
            if let urlSession = _urlSession {
                return urlSession
            }
            else {
                let urlSession = URLSession(configuration: RestClient.defaultURLSessionConfiguration, delegate: FRURLSessionHandler(), delegateQueue: nil)
                _urlSession = urlSession
                print("Default URLSession created")
                
                return urlSession
            }
        }
        set {
            print("Custom URLSession set")
            _urlSession = newValue
        }
    }
    
    
    //  MARK: - Invoke
    
    /// Invokes REST API Request with `Request` object
    ///
    /// - Parameters:
    ///   - request: `Request` object for API request which should contain all information regarding the request
    ///   - action: Optional `Action` object that represents a type of Request
    ///   - completion: `Result` completion callback
    public func invoke(request: Request) async -> Result {
        //  Validate whether `Request` object is valid; otherwise, return an error
        guard let urlRequest = request.build() else {
            return Response(data: nil, response: nil, error: NetworkError.invalidRequest(request.debugDescription)).parseReponse()
        }
 
        do {
            let result = try await self.session.data(for: urlRequest)
            return Response(data: result.0, response: result.1, error: nil).parseReponse()
        }
        catch {
            return Response(data: nil, response: nil, error: error).parseReponse()
        }
        
    }
    
    
    /// Intercepts current Request object, and evaluates with given set of RequestInterceptors to update the original request
    /// - Parameter originalRequest: original Request object
    /// - Returns: updated Request object with given set of RequestInterceptors

    
    //  MARK: - Config
    
    /// Sets custom URLSessionConfiguration for RestClient's URLSession object
    ///
    /// - Parameter config: custom URLSessionConfiguration object
    @objc
    public func setURLSessionConfiguration(config: URLSessionConfiguration) {
        print("Custom URLSessionConfiguration set \(config.debugDescription)")
        let session = URLSession(configuration: config, delegate: FRURLSessionHandler(), delegateQueue: nil)
        self.session = session
    }
    
    /// Sets custom URLSessionConfiguration and delegate Handler for RestClient's URLSession object. This can be used to set SSL Pinning handling
    ///
    /// - Parameter config: custom URLSessionConfiguration object
    /// - Parameter handler: custom FRURLSessionHandler object
    public func setURLSessionConfiguration(config: URLSessionConfiguration?, handler: FRURLSessionHandler?) {
        print("Custom URLSessionConfiguration set \(config.debugDescription), custom delegate handler: \(handler.debugDescription)")
        let session = URLSession(configuration: config ?? RestClient.defaultURLSessionConfiguration, delegate: handler ?? FRURLSessionHandler(), delegateQueue: nil)
        self.session = session
    }
    
    
   
}

extension URLSession {
    
    /// Performs asynchronous HTTP operation
    ///
    /// - Parameter urlrequest: URLRequest object to be performed
    /// - Returns: Result of HTTP operation in tuple
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

