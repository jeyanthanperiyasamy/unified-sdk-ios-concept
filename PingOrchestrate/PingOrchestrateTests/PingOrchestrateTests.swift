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
    
    // Same instance but configuration

    func testExample() async throws {
        
        struct CustomerHeader {
            var name = "jey"
            var age = "bingo"
        }
        
        let header = CustomerHeader()
        
        let customHeader = Module<CustomerHeader>.of(config: header, block: { setup in
            setup.next { request in
                request.url(url: "htttp://andy")
                return request
            }
            
            setup.next { request in
                request.url(url: "htttp://jey")
                return request
            }
        })
        
        let nosession = Module.of(block: { setup in
            setup.next { request in
                request.url(url: "htttp://andy")
                return request
            }
            
            setup.next { request in
                request.url(url: "htttp://bingo")
                return request
            }
        })
        
        
        let forceAuth = Module.of(block: { setup in
            setup.next { request in
                request.url(url: "htttp://stoyan")
                return request
            }
            
            setup.next { request in
                request.url(url: "htttp://vahan")
                return request
            }
        })
        
        
       
        let workFlow = Davinci.config { config in
            config.debug = true
            config.timeout = 10
            
            config.module(block: customHeader, name: ModuleKeys.customHeader.rawValue, config: header)
            
            config.module(block: nosession, name: ModuleKeys.nosession.rawValue)
            
            config.module(block: forceAuth, name: ModuleKeys.forceAuth.rawValue)
           
          
        }
        
        await workFlow.start()
    }

}


