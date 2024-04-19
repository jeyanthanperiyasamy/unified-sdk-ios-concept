//
//  PingOrchestrateTests.swift
//  PingOrchestrateTests
//
//  Created by jey periyasamy on 4/15/24.
//

import XCTest
@testable import PingOrchestrate

final class PingOrchestrateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        let customHeader = Module.of { setup in
            setup.next { request in
                request.url(url: "htttp://andy")
                return request
            }
            
            setup.next { request in
                request.url(url: "htttp://jey")
                return request
            }
        }
        
        let workFlow = Davinci.config { config in
            config.debug = true
            config.timeout = 10
            config.module(block: customHeader, name: "customHeader")
            config.module(block: customHeader, name: "customHeader")
        }
        
        await workFlow.start()
    }

}
