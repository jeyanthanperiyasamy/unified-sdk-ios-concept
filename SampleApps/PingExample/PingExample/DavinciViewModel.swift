//
//  DavinciViewModel.swift
//  PingExample
//
//  Created by jey periyasamy on 4/22/24.
//

import Foundation
import PingOrchestrate
class DavinciViewModel {
    
    func header() {
        func header(request: Request) -> Request {
            request.headers["response_mode"] = "pi.flow"
            request.headers["x-requested-with"] = "forgerock-sdk"
            request.headers["x-requested-platform"] = "ios"
            return request
            }
        
        let sdkHeader = Module.of(block: { setup in
            setup.start { request, _ in
                header(request: request)
            }
            
            setup.next { request, _ in
                header(request: request)
            }
        })
        
        let sessionconfig = SessionConfig()
        
        let Cookie = Module.of(config: sessionconfig, block: { setup in
            setup.start { request, _ in
                header(request: request)
            }
            
            setup.next { request, _ in
                header(request: request)
            }
        })
        
//        Davinci.config { config in
//            config.module(block: <#T##Module<T>#>, name: <#T##String#>)
//        }
    }
    
    
    
}

class SessionConfig {
    var storage = UserDefaults.standard
}

