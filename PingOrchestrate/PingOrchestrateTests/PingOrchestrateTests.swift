//
//  PingOrchestrateTests.swift
//  PingOrchestrateTests
//
//  Created by jey periyasamy on 4/15/24.
//

import XCTest
@testable import PingOrchestrate

final class PingOrchestrateTests: XCTestCase {
    
    
    func testWorkFlow() async throws {
        
        class CustomHeaderConfig {
            var enable = true
            var headerValue = "iOS-SDK"
            var headerName = "header-name"
        }
        
        
        let customHeader = Module.of(config: { CustomHeaderConfig() }, block: { setup in
            let config = setup.config
            setup.next { ( context, request) in
                if config.enable {
                    request.url("https://pingfederate.prod-ping.us1.ping.cloud/")
                    request.header(name: config.headerName, value: config.headerValue)
                }
                return request
            }
            
            setup.start { ( context, request) in
                if config.enable {
                    request.header(name: config.headerName, value: config.headerValue)
                }
                return request
            }
        })
        
        
        let nosession = Module.of(block: { setup in
            setup.next { ( context, request) in
                request.header(name: "nosession", value: "true")
                return request
            }
        })
        
        
        let forceAuth = Module.of(block: { setup in
            setup.start { ( context, request) in
                request.header(name: "forceAuth", value: "true")
                return request
            }
        })
        
        
        
        let workFlow = WorkFlow.config { config in
            config.debug = true
            config.timeout = 10
            
            config.module(block: customHeader, name: ModuleKeys.customHeader.rawValue) { header in
                header.headerName = "iOS-SDK1"
                header.headerValue = "headervalue2"
            }
            
            config.module(block: forceAuth, name: ModuleKeys.forceAuth.rawValue)
            config.module(block: nosession, name: ModuleKeys.nosession.rawValue)
        }
        
        let workFlow1 = WorkFlow.config { config in
            
            config.module(block: customHeader, name: ModuleKeys.customHeader.rawValue) { header in
                header.headerName = "iOS-SDK2"
                header.headerValue = "headervalue3"
            }
            
        }
        
        
        
        _ = await workFlow.start()
        XCTAssertEqual(workFlow.workFlowConfig.modules.count, 3)
        XCTAssertEqual(workFlow1.workFlowConfig.modules.count, 3)
        
    }
    
}


