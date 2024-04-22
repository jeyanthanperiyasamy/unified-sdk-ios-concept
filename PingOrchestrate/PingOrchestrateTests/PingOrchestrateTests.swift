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
        
        class CustomerHeader {
            var name = "jey"
            var age = "bingo"
            
             func update(name: String, age: String) -> CustomerHeader{
                self.name = name
                self.age = age
                return self
            }
        }
        
        let header = CustomerHeader()
        
        let customHeader = Module<CustomerHeader>.of(config: header, block: { setup in
            setup.next { request in
                request.url = header.age
                return request
            }
            
            setup.next { request in
                request.url = "htttp://randy"
                return request
            }
        })
        
        let nosession = Module.of(block: { setup in
            setup.next { request in
                request.url = "htttp://andy"
                return request
            }
            
            setup.next { request in
                request.url = "htttp://andy"
                return request
            }
        })
        
        
        let forceAuth = Module.of(block: { setup in
            setup.next { request in
                request.url = "htttp://andy"
                return request
            }
            
            setup.next { request in
                request.url = "htttp://andy"
                return request
            }
        })
        
        let workFlow = Davinci.config { config in
            
            config.debug = true
            config.timeout = 10
            
            config.module(block: customHeader, name: ModuleKeys.customHeader.rawValue) { header in
                header.age = "20"
                header.name = "40"
            }
            
            config.module(block: nosession, name: ModuleKeys.nosession.rawValue)
            config.module(block: forceAuth, name: ModuleKeys.forceAuth.rawValue)
           
          
        }
        
        await workFlow.start()
        
        
        
    }

}


